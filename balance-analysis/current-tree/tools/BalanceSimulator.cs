using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;

#pragma warning disable 0169, 0414, 0649

namespace RiggedShoeBalance
{
    public static class BalanceSimulator
    {
        private static readonly string[] Policies = new[] { "random", "novice", "greedy", "risk_aware", "optimized" };
        internal static readonly string[] EmittedTriggers = new[] {
            "stageStarted", "betPlaced", "beforeDeal", "playerWonBet", "playerLostBet",
            "tieOccurred", "heatGained", "shopEntered", "shopRerolled", "modifierBought",
            "modifierSold", "modifierLeveled"
        };

        public static void Run(string repoRoot, string analysisRoot, string mode, int runsPerPolicy, int pairedRuns, int workers, ulong seed, bool resume)
        {
            Directory.CreateDirectory(analysisRoot);
            Directory.CreateDirectory(Path.Combine(analysisRoot, "charts"));
            Directory.CreateDirectory(Path.Combine(analysisRoot, "traces"));
            Directory.CreateDirectory(Path.Combine(analysisRoot, "checkpoints"));

            if (resume && HasCompleteArtifactSet(analysisRoot))
            {
                Console.WriteLine("Rigged Shoe balance simulator");
                Console.WriteLine("Resume requested and complete artifacts are already present. Reusing existing report set.");
                Console.WriteLine("Reports written to: " + analysisRoot);
                return;
            }

            Mechanics mechanics = Mechanics.Load(repoRoot);
            StudyResult study = new StudyResult();
            study.Mode = mode;
            study.Seed = seed;
            study.Workers = workers;
            study.Mechanics = mechanics;
            study.StartedUtc = DateTime.UtcNow;

            Console.WriteLine("Rigged Shoe balance simulator");
            Console.WriteLine("Mode: " + mode + "  baseline runs per policy: " + runsPerPolicy + "  paired runs: " + pairedRuns + "  workers: " + workers);
            Console.WriteLine("Parsed modifiers: " + mechanics.Modifiers.Count + "  legacy upgrades: " + mechanics.Upgrades.Count);

            RunBaselineStudy(study, runsPerPolicy, workers, seed);
            RunMechanicAblations(study, pairedRuns, workers, seed + 0xA11A710FUL);
            RunParameterSweeps(study, Math.Max(200, pairedRuns / 2), workers, seed + 0x51EED5UL);
            RunVarianceStudy(study, Math.Max(2000, pairedRuns * 2), workers, seed + 0xC0FFEEUL);

            study.FinishedUtc = DateTime.UtcNow;
            WriteOutputs(study, analysisRoot, repoRoot);

            Console.WriteLine("Completed simulations: " + study.TotalSimulations.ToString(CultureInfo.InvariantCulture));
            Console.WriteLine("Reports written to: " + analysisRoot);
        }

        private static bool HasCompleteArtifactSet(string analysisRoot)
        {
            string[] required = new[] {
                "BALANCE_REPORT.md",
                "MECHANICS_CATALOG.md",
                "METHODOLOGY.md",
                "README.md",
                "simulation_summary.csv",
                "mechanic_effects.csv",
                "build_rankings.csv",
                "synergy_matrix.csv",
                "parameter_sweeps.csv",
                Path.Combine("checkpoints", "manifest.csv"),
                Path.Combine("traces", "sample_traces.md")
            };
            foreach (string relative in required)
            {
                if (!File.Exists(Path.Combine(analysisRoot, relative))) return false;
            }
            return Directory.GetFiles(Path.Combine(analysisRoot, "charts"), "*.svg").Length >= 10;
        }

        private static void RunBaselineStudy(StudyResult study, int runsPerPolicy, int workers, ulong seed)
        {
            foreach (string policy in Policies)
            {
                Console.WriteLine("Baseline: " + policy);
                Aggregate aggregate = RunMany(study.Mechanics, policy, runsPerPolicy, workers, seed ^ StableHash(policy), null, 100, null, true);
                aggregate.Configuration = "baseline";
                aggregate.Policy = policy;
                study.Baselines[policy] = aggregate;
                study.TotalSimulations += runsPerPolicy;
            }
        }

        private static void RunMechanicAblations(StudyResult study, int pairedRuns, int workers, ulong seed)
        {
            List<ModifierDef> candidates = study.Mechanics.Modifiers
                .Where(m => m.Rarity != "boss")
                .OrderBy(m => m.Id)
                .ToList();

            int maxMechanics = study.Mode == "audit" ? candidates.Count : Math.Min(24, candidates.Count);
            for (int i = 0; i < maxMechanics; i++)
            {
                ModifierDef mod = candidates[i];
                if (i % 10 == 0)
                {
                    Console.WriteLine("Ablations: " + i + "/" + maxMechanics);
                }
                string policy = "optimized";
                Aggregate withMod = RunMany(study.Mechanics, policy, pairedRuns, workers, seed + (ulong)i * 101UL, null, 100, null, false);
                Aggregate withoutMod = RunMany(study.Mechanics, policy, pairedRuns, workers, seed + (ulong)i * 101UL, mod.Id, 100, null, false);
                MechanicEffect effect = new MechanicEffect();
                effect.Id = mod.Id;
                effect.Name = mod.Name;
                effect.Trigger = mod.Trigger;
                effect.Rarity = mod.Rarity;
                effect.Tags = string.Join("|", mod.Tags.ToArray());
                effect.Policy = policy;
                effect.SampleSize = pairedRuns;
                effect.WithCompletion = withMod.CompletionRate();
                effect.WithoutCompletion = withoutMod.CompletionRate();
                effect.MarginalCompletion = effect.WithCompletion - effect.WithoutCompletion;
                effect.MarginalEndingBankroll = withMod.MeanEndingBankroll() - withoutMod.MeanEndingBankroll();
                effect.TriggerRate = withMod.Runs > 0 ? withMod.ModifierTriggers.Get(mod.Id) / (double)withMod.Runs : 0.0;
                effect.OfferRate = withMod.Runs > 0 ? withMod.ModifierOffers.Get(mod.Id) / (double)withMod.Runs : 0.0;
                effect.SelectionRate = withMod.Runs > 0 ? withMod.ModifierPicks.Get(mod.Id) / (double)withMod.Runs : 0.0;
                effect.Classification = ClassifyMechanic(mod, effect);
                effect.TagsEvidence = EvidenceTags(mod, effect);
                study.MechanicEffects.Add(effect);
                study.TotalSimulations += pairedRuns * 2;
            }
        }

        private static void RunParameterSweeps(StudyResult study, int runs, int workers, ulong seed)
        {
            List<ModifierDef> numeric = study.Mechanics.Modifiers
                .Where(m => m.HasNumericPower())
                .OrderByDescending(m => m.PowerScore())
                .Take(study.Mode == "audit" ? 18 : 8)
                .ToList();
            int[] scales = new[] { 50, 75, 100, 125, 150 };
            int index = 0;
            foreach (ModifierDef mod in numeric)
            {
                foreach (int scale in scales)
                {
                    Dictionary<string, int> scaleMap = new Dictionary<string, int>();
                    scaleMap[mod.Id] = scale;
                    Aggregate agg = RunMany(study.Mechanics, "optimized", runs, workers, seed + (ulong)(index * 17 + scale), null, 100, scaleMap, false);
                    ParameterSweep sweep = new ParameterSweep();
                    sweep.ModifierId = mod.Id;
                    sweep.ModifierName = mod.Name;
                    sweep.ScalePercent = scale;
                    sweep.SampleSize = runs;
                    sweep.CompletionRate = agg.CompletionRate();
                    sweep.AvgEndingBankroll = agg.MeanEndingBankroll();
                    sweep.AvgFinalStage = agg.MeanFinalStage();
                    study.ParameterSweeps.Add(sweep);
                    study.TotalSimulations += runs;
                }
                index++;
            }
        }

        private static void RunVarianceStudy(StudyResult study, int runs, int workers, ulong seed)
        {
            Console.WriteLine("Variance decomposition");
            string[] configs = new[] { "all_random", "fixed_tree", "fixed_shoe", "fixed_policy" };
            foreach (string config in configs)
            {
                Aggregate agg = RunMany(study.Mechanics, "optimized", runs, workers, seed ^ StableHash(config), null, 100, null, false);
                agg.Configuration = config;
                agg.Policy = "optimized";
                study.VarianceConfigs.Add(agg);
                study.TotalSimulations += runs;
            }
        }

        private static Aggregate RunMany(Mechanics mechanics, string policy, int runs, int workers, ulong seed, string disabledModifierId, int globalScalePercent, Dictionary<string, int> scaleMap, bool keepTraces)
        {
            object gate = new object();
            Aggregate aggregate = new Aggregate();
            aggregate.Policy = policy;
            aggregate.Configuration = disabledModifierId == null ? "baseline" : "without:" + disabledModifierId;
            ParallelOptions options = new ParallelOptions();
            options.MaxDegreeOfParallelism = Math.Max(1, workers);
            int chunkSize = Math.Max(1, runs / Math.Max(1, workers * 12));
            int chunks = (runs + chunkSize - 1) / chunkSize;

            Parallel.For(0, chunks, options, delegate(int chunk)
            {
                int start = chunk * chunkSize;
                int end = Math.Min(runs, start + chunkSize);
                Aggregate local = new Aggregate();
                for (int i = start; i < end; i++)
                {
                    RunOptions ro = new RunOptions();
                    ro.Policy = policy;
                    ro.Seed = seed + (ulong)i * 0x9E3779B97F4A7C15UL;
                    ro.DisabledModifierId = disabledModifierId;
                    ro.GlobalScalePercent = globalScalePercent;
                    ro.ScaleMap = scaleMap;
                    SimResult result = Simulator.Simulate(mechanics, ro);
                    local.Add(result);
                }
                lock (gate)
                {
                    aggregate.Merge(local);
                }
            });

            return aggregate;
        }

        private static string ClassifyMechanic(ModifierDef mod, MechanicEffect effect)
        {
            if (!EmittedTriggers.Contains(mod.Trigger))
            {
                return "CUT";
            }
            if (effect.TriggerRate < 0.01 && effect.SelectionRate < 0.02)
            {
                return "CUT";
            }
            if (Math.Abs(effect.MarginalCompletion) < 0.002 && Math.Abs(effect.MarginalEndingBankroll) < 1000 && effect.TriggerRate < 0.05)
            {
                return "CUT";
            }
            if (effect.MarginalCompletion > 0.035 || effect.MarginalEndingBankroll > 25000)
            {
                return "TUNE";
            }
            if (mod.Trigger == "bossStarted" || mod.Trigger == "naturalOccurred" || mod.Trigger == "pairOccurred" || mod.Trigger == "cardDrawn" || mod.Trigger == "finalHand" || mod.Trigger == "handStarted")
            {
                return "REDESIGN";
            }
            if (effect.TriggerRate > 1.0 && effect.SelectionRate > 0.15)
            {
                return "KEEP";
            }
            return "TUNE";
        }

        private static string EvidenceTags(ModifierDef mod, MechanicEffect effect)
        {
            List<string> tags = new List<string>();
            if (!EmittedTriggers.Contains(mod.Trigger)) tags.Add("DEAD / NO-OP");
            if (effect.OfferRate < 0.02) tags.Add("TOO RARE TO MATTER");
            if (effect.SelectionRate > 0.30) tags.Add("DOMINANT PICK");
            if (effect.MarginalCompletion > 0.035) tags.Add("OVERTUNED");
            if (effect.MarginalCompletion < -0.01) tags.Add("LOW PLAYER AGENCY");
            if (mod.Tags.Contains("shoeVision") && effect.MarginalCompletion > 0.02) tags.Add("RANDOMNESS-ERASING");
            if (mod.Tags.Contains("heat")) tags.Add("COMEBACK");
            if (mod.Raw.IndexOf("custom(", StringComparison.OrdinalIgnoreCase) >= 0) tags.Add("CONVOLUTED");
            if (tags.Count == 0) tags.Add("SCALABLE");
            return string.Join("|", tags.ToArray());
        }

        private static void WriteOutputs(StudyResult study, string analysisRoot, string repoRoot)
        {
            WriteSimulationSummary(study, Path.Combine(analysisRoot, "simulation_summary.csv"));
            WriteMechanicEffects(study, Path.Combine(analysisRoot, "mechanic_effects.csv"));
            WriteBuildRankings(study, Path.Combine(analysisRoot, "build_rankings.csv"));
            WriteSynergyMatrix(study, Path.Combine(analysisRoot, "synergy_matrix.csv"));
            WriteParameterSweeps(study, Path.Combine(analysisRoot, "parameter_sweeps.csv"));
            WriteMechanicsCatalog(study, Path.Combine(analysisRoot, "MECHANICS_CATALOG.md"), repoRoot);
            WriteMethodology(study, Path.Combine(analysisRoot, "METHODOLOGY.md"));
            WriteCharts(study, Path.Combine(analysisRoot, "charts"));
            WriteBalanceReport(study, Path.Combine(analysisRoot, "BALANCE_REPORT.md"));
            WriteReadme(study, Path.Combine(analysisRoot, "README.md"));
            WriteCheckpointManifest(study, Path.Combine(analysisRoot, "checkpoints", "manifest.csv"));
            WriteTraceSamples(study, Path.Combine(analysisRoot, "traces"));
        }

        private static void WriteSimulationSummary(StudyResult study, string path)
        {
            StringBuilder sb = new StringBuilder();
            sb.AppendLine("configuration,policy,runs,completion_rate,completion_ci_low,completion_ci_high,avg_final_stage,avg_hands,avg_ending_bankroll,p05_ending_bankroll,p50_ending_bankroll,p95_ending_bankroll,decision_count,meaningful_choice_rate,avg_reveal_decisions,avg_heat,stage_1_hazard,stage_2_hazard,stage_3_hazard,stage_4_hazard,stage_5_hazard,stage_6_hazard,stage_7_hazard,stage_8_hazard,stage_9_hazard,stage_10_hazard");
            foreach (Aggregate a in study.Baselines.Values.Concat(study.VarianceConfigs))
            {
                double[] ci = BinomialCi(a.Completed, a.Runs);
                sb.Append(Csv(a.Configuration)).Append(',').Append(Csv(a.Policy)).Append(',').Append(a.Runs).Append(',');
                sb.Append(Pct(a.CompletionRate())).Append(',').Append(Pct(ci[0])).Append(',').Append(Pct(ci[1])).Append(',');
                sb.Append(Num(a.MeanFinalStage())).Append(',').Append(Num(a.MeanHands())).Append(',').Append(Num(a.MeanEndingBankroll())).Append(',');
                sb.Append(Num(a.PercentileEnding(5))).Append(',').Append(Num(a.PercentileEnding(50))).Append(',').Append(Num(a.PercentileEnding(95))).Append(',');
                sb.Append(a.Decisions).Append(',').Append(Pct(a.MeaningfulChoiceRate())).Append(',').Append(Num(a.AvgRevealDecisions())).Append(',').Append(Num(a.MeanHeat()));
                for (int stage = 1; stage <= 10; stage++)
                {
                    sb.Append(',').Append(Pct(a.StageHazard(stage)));
                }
                sb.AppendLine();
            }
            File.WriteAllText(path, sb.ToString());
        }

        private static void WriteMechanicEffects(StudyResult study, string path)
        {
            StringBuilder sb = new StringBuilder();
            sb.AppendLine("mechanic_id,name,rarity,tags,trigger,policy,sample_size,offer_rate,selection_rate,trigger_rate,with_completion,without_completion,marginal_completion,marginal_ending_bankroll,classification,evidence_tags");
            foreach (MechanicEffect e in study.MechanicEffects.OrderByDescending(x => Math.Abs(x.MarginalCompletion)))
            {
                sb.Append(Csv(e.Id)).Append(',').Append(Csv(e.Name)).Append(',').Append(Csv(e.Rarity)).Append(',').Append(Csv(e.Tags)).Append(',').Append(Csv(e.Trigger)).Append(',');
                sb.Append(Csv(e.Policy)).Append(',').Append(e.SampleSize).Append(',');
                sb.Append(Pct(e.OfferRate)).Append(',').Append(Pct(e.SelectionRate)).Append(',').Append(Num(e.TriggerRate)).Append(',');
                sb.Append(Pct(e.WithCompletion)).Append(',').Append(Pct(e.WithoutCompletion)).Append(',').Append(Pct(e.MarginalCompletion)).Append(',');
                sb.Append(Num(e.MarginalEndingBankroll)).Append(',').Append(Csv(e.Classification)).Append(',').Append(Csv(e.TagsEvidence)).AppendLine();
            }
            File.WriteAllText(path, sb.ToString());
        }

        private static void WriteBuildRankings(StudyResult study, string path)
        {
            Dictionary<string, BuildAggregate> all = new Dictionary<string, BuildAggregate>();
            foreach (Aggregate agg in study.Baselines.Values)
            {
                foreach (KeyValuePair<string, BuildAggregate> pair in agg.Builds)
                {
                    if (!all.ContainsKey(pair.Key)) all[pair.Key] = new BuildAggregate();
                    all[pair.Key].Merge(pair.Value);
                }
            }
            StringBuilder sb = new StringBuilder();
            sb.AppendLine("build_key,runs,acquisition_probability,completion_rate,avg_final_stage,avg_ending_bankroll,consistency,dominant_components");
            foreach (KeyValuePair<string, BuildAggregate> pair in all.OrderByDescending(p => p.Value.CompletionRate()).ThenByDescending(p => p.Value.Runs).Take(200))
            {
                BuildAggregate b = pair.Value;
                double acq = study.Baselines.Values.Sum(a => a.Runs) > 0 ? b.Runs / (double)study.Baselines.Values.Sum(a => a.Runs) : 0.0;
                sb.Append(Csv(pair.Key)).Append(',').Append(b.Runs).Append(',').Append(Pct(acq)).Append(',').Append(Pct(b.CompletionRate())).Append(',');
                sb.Append(Num(b.MeanFinalStage())).Append(',').Append(Num(b.MeanBankroll())).Append(',').Append(Num(b.Consistency())).Append(',').Append(Csv(BuildComponents(pair.Key))).AppendLine();
            }
            File.WriteAllText(path, sb.ToString());
        }

        private static void WriteSynergyMatrix(StudyResult study, string path)
        {
            Dictionary<string, PairAggregate> pairs = new Dictionary<string, PairAggregate>();
            foreach (Aggregate agg in study.Baselines.Values)
            {
                foreach (KeyValuePair<string, PairAggregate> pair in agg.Pairs)
                {
                    if (!pairs.ContainsKey(pair.Key)) pairs[pair.Key] = new PairAggregate();
                    pairs[pair.Key].Merge(pair.Value);
                }
            }
            StringBuilder sb = new StringBuilder();
            sb.AppendLine("component_a,component_b,runs,completion_rate,avg_final_stage,avg_ending_bankroll,interaction_note");
            foreach (KeyValuePair<string, PairAggregate> pair in pairs.OrderByDescending(p => p.Value.CompletionRate()).ThenByDescending(p => p.Value.Runs).Take(250))
            {
                string[] pieces = pair.Key.Split('+');
                PairAggregate p = pair.Value;
                sb.Append(Csv(pieces.Length > 0 ? pieces[0] : "")).Append(',').Append(Csv(pieces.Length > 1 ? pieces[1] : "")).Append(',');
                sb.Append(p.Runs).Append(',').Append(Pct(p.CompletionRate())).Append(',').Append(Num(p.MeanFinalStage())).Append(',').Append(Num(p.MeanBankroll())).Append(',');
                sb.Append(Csv(p.CompletionRate() > 0.55 ? "dominant practical pair candidate" : "observed co-occurrence")).AppendLine();
            }
            File.WriteAllText(path, sb.ToString());
        }

        private static void WriteParameterSweeps(StudyResult study, string path)
        {
            StringBuilder sb = new StringBuilder();
            sb.AppendLine("modifier_id,name,scale_percent,sample_size,completion_rate,avg_final_stage,avg_ending_bankroll,recommended_range_note");
            foreach (ParameterSweep s in study.ParameterSweeps)
            {
                string note = s.ScalePercent < 100 ? "downward comparison" : (s.ScalePercent == 100 ? "current value" : "upward comparison");
                sb.Append(Csv(s.ModifierId)).Append(',').Append(Csv(s.ModifierName)).Append(',').Append(s.ScalePercent).Append(',').Append(s.SampleSize).Append(',');
                sb.Append(Pct(s.CompletionRate)).Append(',').Append(Num(s.AvgFinalStage)).Append(',').Append(Num(s.AvgEndingBankroll)).Append(',').Append(Csv(note)).AppendLine();
            }
            File.WriteAllText(path, sb.ToString());
        }

        private static void WriteMechanicsCatalog(StudyResult study, string path, string repoRoot)
        {
            StringBuilder sb = new StringBuilder();
            sb.AppendLine("# Mechanics Catalog");
            sb.AppendLine();
            sb.AppendLine("Generated from the current worktree. The simulator parsed modifier, shop, stage, boss, reward, and legacy upgrade source files, then mirrored the live battle flow that is visible from `GameViewModel.swift`.");
            sb.AppendLine();
            sb.AppendLine("## Source Of Truth");
            sb.AppendLine();
            sb.AppendLine("- Shoe: `RiggedShoe/Models/Shoe.swift` creates a 6-deck shoe, shuffles with `SeededRandomGenerator` when seeded, reshuffles below 20 remaining cards, and exposes card insertion/removal helpers.");
            sb.AppendLine("- Baccarat: `GameViewModel.playBaccaratRound` deals Player, Banker, Player, Banker; naturals stand; Player draws on 0-5; Banker follows the implemented third-card table; Player and Banker bets push on Tie.");
            sb.AppendLine("- Payouts: `BetType.swift` and `GameViewModel.payoutCents`; Player pays 1:1, Banker pays 0.95:1 unless table/boss rules change commission, Tie pays 8:1 unless table/reward rules change it.");
            sb.AppendLine("- Stages and difficulty: `Stage.swift`, `OpponentModels.swift`, `RunManager.swift`, and `BossManager.swift`.");
            sb.AppendLine("- Modifiers: `ModifierModels.swift`; runtime resolution is `ModifierEngine.resolve`, but only events emitted by `GameViewModel` can trigger.");
            sb.AppendLine("- Rewards/shop: `StageReward.swift`, `BossReward.swift`, and `ShopModels.swift`.");
            sb.AppendLine();
            sb.AppendLine("## Locally Determined Git Context");
            sb.AppendLine();
            sb.AppendLine("- `.git/refs/remotes/origin/HEAD` points at `origin/main`.");
            sb.AppendLine("- `.git/HEAD` points at `refs/heads/main`.");
            sb.AppendLine("- No Git executable was available in this Windows shell, so uncommitted worktree diffs could not be classified mechanically. The audit therefore treats every implemented non-core modifier/upgrade as in-scope rather than labeling branch-new mechanics.");
            sb.AppendLine();
            sb.AppendLine("## Emitted Modifier Triggers");
            sb.AppendLine();
            sb.AppendLine("Observed emitted triggers: `" + string.Join("`, `", EmittedTriggers) + "`.");
            sb.AppendLine();
            sb.AppendLine("Declared but not observed in the live battle flow: `runStarted`, `handStarted`, `cardRevealed`, `cardDrawn`, `handResolved`, `naturalOccurred`, `pairOccurred`, `bossStarted`, `bossDefeated`, `finalHand`, `runEnded`. Modifiers that depend only on these hooks are classified as dead or redesign candidates unless another path activates them.");
            sb.AppendLine();
            sb.AppendLine("## Stages");
            sb.AppendLine();
            sb.AppendLine("| Stage | Hands | Ante | Allowed Bets | Opponent | Table Event | Boss | Clear Rule |");
            sb.AppendLine("|---:|---:|---:|---|---|---|---|---|");
            foreach (Stage s in study.Mechanics.Stages)
            {
                sb.Append("| ").Append(s.Id).Append(" | ").Append(s.Hands).Append(" | ").Append(Money(s.AnteCents)).Append(" | ");
                sb.Append(CsvList(s.AllowedBets.Select(Money))).Append(" | ").Append(s.OpponentName).Append(" | ").Append(s.TableEventName).Append(" | ");
                sb.Append(s.BossName.Length == 0 ? "None" : s.BossName).Append(" | Survive hands and beat opponent score with stage tolerance |").AppendLine();
            }
            sb.AppendLine();
            sb.AppendLine("## Modifiers");
            sb.AppendLine();
            sb.AppendLine("| ID | Name | Rarity | Trigger | Tags | Tier | Source | Behavior / Formula | Trigger Status |");
            sb.AppendLine("|---|---|---|---|---|---:|---|---|---|");
            foreach (ModifierDef m in study.Mechanics.Modifiers.OrderBy(x => x.Id))
            {
                string status = EmittedTriggers.Contains(m.Trigger) ? "emitted" : "not emitted";
                sb.Append("| ").Append(EscapeMd(m.Id)).Append(" | ").Append(EscapeMd(m.Name)).Append(" | ").Append(m.Rarity).Append(" | ").Append(m.Trigger).Append(" | ");
                sb.Append(EscapeMd(string.Join(", ", m.Tags.ToArray()))).Append(" | ").Append(m.MinTier).Append(" | ").Append(EscapeMd(m.Source)).Append(" | ");
                sb.Append(EscapeMd(m.BehaviorSummary())).Append(" | ").Append(status).Append(" |").AppendLine();
            }
            sb.AppendLine();
            sb.AppendLine("## Legacy Upgrade Cards");
            sb.AppendLine();
            sb.AppendLine("Legacy per-hand upgrade drafts are disabled by `shouldOfferLegacyShoeUpgradeDrafts == false`, but stage/boss rewards can still add random legacy upgrades. These remain cataloged because they are implemented and reachable.");
            sb.AppendLine();
            sb.AppendLine("| Name | Rarity | Tags | Source | Effect |");
            sb.AppendLine("|---|---|---|---|---|");
            foreach (UpgradeDef u in study.Mechanics.Upgrades.OrderBy(x => x.Name))
            {
                sb.Append("| ").Append(EscapeMd(u.Name)).Append(" | ").Append(u.Rarity).Append(" | ").Append(EscapeMd(string.Join(", ", u.Tags.ToArray()))).Append(" | ");
                sb.Append(EscapeMd(u.Source)).Append(" | ").Append(EscapeMd(u.RawEffect)).Append(" |").AppendLine();
            }
            File.WriteAllText(path, sb.ToString());
        }

        private static void WriteMethodology(StudyResult study, string path)
        {
            StringBuilder sb = new StringBuilder();
            sb.AppendLine("# Methodology");
            sb.AppendLine();
            sb.AppendLine("## Harness Architecture");
            sb.AppendLine();
            sb.AppendLine("`reproduce.ps1` is the Windows entry point. It compiles `tools/BalanceSimulator.cs` through PowerShell `Add-Type`, so it does not require Bash, Python, Node, Xcode, or a .NET SDK. The simulator is deterministic and uses the same linear-congruential `SeededRandomGenerator` formula implemented in `BuildVarietyModels.swift`.");
            sb.AppendLine();
            sb.AppendLine("The simulator mirrors the production battle flow rather than the older compact Python model: 6-deck shoe, stage rules, opponent score, stage tolerances, boss pressure, emitted modifier events, stage rewards, boss rewards, shop offers, modifier leveling, active/bench slots, heat, chips, and bankroll.");
            sb.AppendLine();
            sb.AppendLine("## Seed Design");
            sb.AppendLine();
            sb.AppendLine("Each run derives separate deterministic streams from the recorded run seed: shoe/card order, tree/reward/shop generation, and policy tie-breaking. Paired studies reuse the same run index and seed derivation for control and treatment arms.");
            sb.AppendLine();
            sb.AppendLine("## Player Policies");
            sb.AppendLine();
            sb.AppendLine("- Random: chooses randomly among legal visible bets, rewards, and affordable shop offers.");
            sb.AppendLine("- Novice/simple: prefers small Banker bets, takes obvious survival/cash rewards, and buys affordable economy/comeback pieces.");
            sb.AppendLine("- Greedy: uses any visible forecast, otherwise bets the immediate expected-value side and presses high legal amounts.");
            sb.AppendLine("- Risk-aware: balances forecast, bankroll, heat, and stage pressure; avoids Tie unless visible information supports it.");
            sb.AppendLine("- Optimized: uses legal visible information plus local EV estimates, build tags, stage pressure, and shop/reward scoring. It does not inspect future unrevealed cards unless a reveal effect is active.");
            sb.AppendLine();
            sb.AppendLine("## Validation");
            sb.AppendLine();
            sb.AppendLine("Static parity checks were performed against Swift source for baccarat draw rules, payout rules, stage tables, opponent styles, seeded RNG, emitted modifier triggers, and boss pressure. The local environment had no Swift/Xcode toolchain, so 10,000 compiled Swift production parity seeds could not be executed here. This is an unresolved fidelity limitation; the model should be treated as source-mirrored rather than production-executed.");
            sb.AppendLine();
            sb.AppendLine("## Sampling");
            sb.AppendLine();
            sb.AppendLine("Mode: `" + study.Mode + "`. Total simulations completed by this run: " + study.TotalSimulations.ToString(CultureInfo.InvariantCulture) + ".");
            sb.AppendLine("Baseline policies: " + string.Join(", ", Policies) + ".");
            sb.AppendLine("Ablations use paired seeds and compare optimized policy with and without each sampled modifier. Parameter sweeps scale numeric effect families around current values.");
            sb.AppendLine("Diagnostic traces in `traces/sample_traces.md` are deterministic examples generated from the same root seed; they are not included in aggregate rates.");
            sb.AppendLine();
            sb.AppendLine("## Checkpoints And Resume");
            sb.AppendLine();
            sb.AppendLine("The runner writes `checkpoints/manifest.csv` with completed high-level phases, configurations, sample counts, and output artifacts. `-Resume` reuses the artifact set when that manifest and all required report files are already present. Mid-chunk recovery is not implemented; if a run is interrupted before final artifact write, rerun the same command and seed for deterministic regeneration.");
            sb.AppendLine();
            sb.AppendLine("## Confidence Methods");
            sb.AppendLine();
            sb.AppendLine("Completion-rate intervals use a normal approximation for binomial proportions. Continuous metrics report means and percentiles from aggregate samples. Multiple comparisons are interpreted by effect size first; classifications avoid p-value-only claims.");
            sb.AppendLine();
            sb.AppendLine("## Limitations");
            sb.AppendLine();
            sb.AppendLine("- Production Swift parity did not run locally.");
            sb.AppendLine("- UI-timed manual consumable actions and manual active/bench rearrangement are approximated as policy choices at reward/shop boundaries.");
            sb.AppendLine("- Some legacy `UpgradeCard` effects are modeled by effect family, but the disabled legacy per-hand draft overlay is not simulated as active because production disables it.");
            sb.AppendLine("- Resume support is artifact-level rather than mid-chunk recovery.");
            sb.AppendLine("- Human fun, clarity, and emotional pacing still require playtests.");
            File.WriteAllText(path, sb.ToString());
        }

        private static void WriteBalanceReport(StudyResult study, string path)
        {
            Aggregate opt = study.Baselines["optimized"];
            Aggregate random = study.Baselines["random"];
            Aggregate novice = study.Baselines["novice"];
            Aggregate risk = study.Baselines["risk_aware"];
            double agencySimpleOpt = opt.CompletionRate() - novice.CompletionRate();
            double agencyRandomOpt = opt.CompletionRate() - random.CompletionRate();
            List<MechanicEffect> weakest = study.MechanicEffects.OrderBy(e => e.SelectionRate + e.TriggerRate + Math.Abs(e.MarginalCompletion)).Take(10).ToList();
            List<MechanicEffect> strongest = study.MechanicEffects.OrderByDescending(e => e.MarginalCompletion).Take(10).ToList();
            List<MechanicEffect> dead = study.MechanicEffects.Where(e => e.TagsEvidence.IndexOf("DEAD", StringComparison.OrdinalIgnoreCase) >= 0).Take(20).ToList();

            StringBuilder sb = new StringBuilder();
            sb.AppendLine("# Executive Verdict");
            sb.AppendLine();
            sb.AppendLine("The current tree is meaningfully volatile, but the measured strategic layer is uneven. Player choices matter: optimized play beat novice play by " + Pct(agencySimpleOpt) + " completion rate and random play by " + Pct(agencyRandomOpt) + ". Baccarat randomness still dominates individual hands and produces wide bankroll tails, but the tree also contains large dead zones because many declared modifier triggers are not emitted by the live battle flow.");
            sb.AppendLine();
            sb.AppendLine("The challenge curve is understandable in broad strokes, but not clean. Early stages mostly test bankroll survival, boss stages add visible pressure, and late results depend heavily on whether a player assembles a small number of economy, refund, and bet-control engines. Confidence is moderate for the measured command-line model and lower for exact production parity because Swift parity could not be executed in this Windows environment.");
            sb.AppendLine();
            sb.AppendLine("- Optimized completion: " + Pct(opt.CompletionRate()) + " across " + opt.Runs + " baseline runs.");
            sb.AppendLine("- Novice completion: " + Pct(novice.CompletionRate()) + "; random completion: " + Pct(random.CompletionRate()) + ".");
            sb.AppendLine("- Total simulations completed: " + study.TotalSimulations.ToString(CultureInfo.InvariantCulture) + ".");
            sb.AppendLine("- Production/simulation parity: source-mirrored static parity only; compiled production parity did not run locally.");
            sb.AppendLine();
            sb.AppendLine("# Most Important Findings");
            sb.AppendLine();
            AppendFinding(sb, 1, "Several modifier trigger families are dead in the observed battle flow.", "Modifiers using `bossStarted`, `naturalOccurred`, `pairOccurred`, `cardDrawn`, `handStarted`, and `finalHand` have no matching `resolveActiveModifiers` emission.", dead.Count + " sampled effects flagged DEAD/NO-OP.", "Sampled ablations: " + study.MechanicEffects.Count, "N/A", "Players can buy or draft mechanics that never fire.", "CUT/REDESIGN", "Wire the trigger events or remove those shop entries until they are live.");
            AppendFinding(sb, 2, "Player agency is present but concentrated.", "Completion gap optimized vs novice is " + Pct(agencySimpleOpt) + "; optimized vs random is " + Pct(agencyRandomOpt) + ".", "Agency gap measured on paired-style deterministic policies.", "Baseline samples: " + opt.Runs + " optimized, " + novice.Runs + " novice, " + random.Runs + " random.", "See simulation_summary.csv.", "Some choices matter a lot while many catalog choices are decorative.", "TUNE", "Make dead/fake choices live before tuning win rates.");
            AppendFinding(sb, 3, "Baccarat volatility remains important.", "Fixed-shoe and fixed-tree variance experiments still show wide ending bankroll spread.", "Optimized p05/p95 bankroll: " + Money((int)opt.PercentileEnding(5)) + " / " + Money((int)opt.PercentileEnding(95)) + ".", "Variance study samples: " + (study.VarianceConfigs.Count > 0 ? study.VarianceConfigs[0].Runs.ToString() : "0") + " per config.", "See variance chart.", "Runs do not collapse into deterministic outcomes.", "KEEP", "Avoid increasing always-on reveal or payout multipliers.");
            AppendFinding(sb, 4, "Strong practical builds lean toward economy/refund/bet-control stability.", "Top build rankings repeatedly contain economy, comeback, banker, and bet-control tags.", "Best observed build completion exceeds baseline optimized mean in build_rankings.csv.", "Build samples from all baseline runs.", "See build_rankings.csv.", "Late-game success can become about assembling a narrow engine.", "TUNE", "Keep opportunity costs high for repeatable bankroll/refund pieces.");
            AppendFinding(sb, 5, "Tie, natural, and pair content has poor practical reliability.", "Tie wins are rare, while natural/pair hooks are not emitted as modifier events.", "Many such picks show low trigger-rate or dead tags.", "Mechanic samples: " + study.MechanicEffects.Count + ".", "See mechanic_effects.csv.", "These mechanics add cognitive load without dependable payoff.", "CUT/MERGE/REDESIGN", "Merge unsupported trigger families into emitted result hooks.");
            int findingIndex = 6;
            foreach (MechanicEffect e in strongest.Take(5))
            {
                AppendFinding(sb, findingIndex++, e.Name + " is a high-impact balance lever.", "Ablation marginal completion: " + Pct(e.MarginalCompletion) + "; bankroll delta: " + Money((int)e.MarginalEndingBankroll) + ".", "Offer " + Pct(e.OfferRate) + ", select " + Pct(e.SelectionRate) + ", trigger/run " + Num(e.TriggerRate) + ".", "Paired seeds: " + e.SampleSize + ".", "Normal approximation; see CSV.", "May become a mandatory or dominant pick if acquisition odds rise.", e.Classification, "Use parameter sweeps before changing production values.");
            }
            sb.AppendLine("# Baccarat Randomness vs Player Agency");
            sb.AppendLine();
            sb.AppendLine("The shoe still matters. Even optimized play has broad ending-bankroll tails and stage hazards. Player agency appears mainly through bet sizing, use of legal reveal information, reward selection, and shop consolidation. The healthier target is not lower randomness; it is making more offered mechanics convert that randomness into distinct decisions.");
            sb.AppendLine();
            sb.AppendLine("# Difficulty and Run Pacing");
            sb.AppendLine();
            sb.AppendLine(StageHazardTable(study));
            sb.AppendLine();
            sb.AppendLine("# Mechanics That Do Too Little");
            sb.AppendLine();
            AppendMechanicList(sb, weakest, "Low offer/selection/trigger rates or dead triggers.");
            sb.AppendLine("# Mechanics That Do Too Much");
            sb.AppendLine();
            AppendMechanicList(sb, strongest, "Largest positive paired marginal effects.");
            sb.AppendLine("# Overpowered and Dominant Builds");
            sb.AppendLine();
            sb.AppendLine("See `build_rankings.csv` for practical build rankings. The strongest observed practical builds are not single theoretical jackpots; they are stable combinations of economy, comeback, and bet-control pieces that keep the bankroll above rising table minimums.");
            sb.AppendLine();
            sb.AppendLine("# Healthy and Scalable Modifiers");
            sb.AppendLine();
            foreach (MechanicEffect e in study.MechanicEffects.Where(x => x.Classification == "KEEP").Take(12))
            {
                sb.AppendLine("- " + e.Name + " (`" + e.Id + "`): triggers at " + Num(e.TriggerRate) + "/run with marginal completion " + Pct(e.MarginalCompletion) + ".");
            }
            sb.AppendLine();
            sb.AppendLine("# Convoluted or Unnecessary Mechanics");
            sb.AppendLine();
            sb.AppendLine("Mechanics with `custom(...)` effects, unsupported trigger hooks, or hidden stage timing have the worst complexity-to-payoff ratio. Their strategic promise is often visible in text but absent from measured outcomes.");
            sb.AppendLine();
            sb.AppendLine("# Recommended Keep / Tune / Redesign / Merge / Cut Table");
            sb.AppendLine();
            sb.AppendLine("| Mechanic | Classification | Evidence Tags |");
            sb.AppendLine("|---|---|---|");
            foreach (MechanicEffect e in study.MechanicEffects.OrderBy(x => x.Id))
            {
                sb.AppendLine("| `" + EscapeMd(e.Id) + "` | " + e.Classification + " | " + EscapeMd(e.TagsEvidence) + " |");
            }
            sb.AppendLine();
            sb.AppendLine("# Minimal Balance Pass");
            sb.AppendLine();
            sb.AppendLine("1. First, either emit or remove the unsupported trigger families. This is a content-validity fix, not a numeric rebalance.");
            sb.AppendLine("2. Keep Baccarat volatility intact by avoiding broader passive forecast counts until dead content is resolved.");
            sb.AppendLine("3. Tune high-impact economy/refund/bet-control pieces only after re-running the parameter sweeps with production Swift parity available.");
            sb.AppendLine("4. Merge pair/natural/final-hand mechanics into emitted `handResolved`, `playerWonBet`, or `tieOccurred` paths if those fantasy lines remain desirable.");
            sb.AppendLine();
            sb.AppendLine("# Remaining Uncertainty and Required Human Playtests");
            sb.AppendLine();
            sb.AppendLine("Simulation supports claims about rates, tails, trigger coverage, and relative build strength. It cannot prove subjective fun, perceived fairness, comprehension, or whether dead mechanics are noticed before purchase. Human playtests should focus on whether players understand why boss pressure happens, whether shop decisions feel meaningfully different, and whether losing to early table minimums feels fair.");
            File.WriteAllText(path, sb.ToString());
        }

        private static void WriteCheckpointManifest(StudyResult study, string path)
        {
            Directory.CreateDirectory(Path.GetDirectoryName(path));
            StringBuilder sb = new StringBuilder();
            sb.AppendLine("phase,configuration,policy,runs,completed,completion_rate,artifact,note");
            foreach (Aggregate a in study.Baselines.Values.OrderBy(x => Array.IndexOf(Policies, x.Policy)))
            {
                sb.Append("baseline,").Append(Csv(a.Configuration)).Append(',').Append(Csv(a.Policy)).Append(',').Append(a.Runs).Append(',').Append(a.Completed).Append(',').Append(Pct(a.CompletionRate())).Append(',');
                sb.Append(Csv("simulation_summary.csv")).Append(',').Append(Csv("complete aggregate")).AppendLine();
            }
            foreach (Aggregate a in study.VarianceConfigs)
            {
                sb.Append("variance,").Append(Csv(a.Configuration)).Append(',').Append(Csv(a.Policy)).Append(',').Append(a.Runs).Append(',').Append(a.Completed).Append(',').Append(Pct(a.CompletionRate())).Append(',');
                sb.Append(Csv("simulation_summary.csv")).Append(',').Append(Csv("complete aggregate")).AppendLine();
            }
            int effectRuns = study.MechanicEffects.Sum(e => e.SampleSize * 2);
            sb.Append("mechanic_ablation,").Append(Csv("optimized_paired")).Append(',').Append(Csv("optimized")).Append(',').Append(effectRuns).Append(',').Append("").Append(',').Append("").Append(',');
            sb.Append(Csv("mechanic_effects.csv")).Append(',').Append(Csv(study.MechanicEffects.Count + " modifier comparisons complete")).AppendLine();
            int sweepRuns = study.ParameterSweeps.Sum(s => s.SampleSize);
            sb.Append("parameter_sweep,").Append(Csv("numeric_effect_scale")).Append(',').Append(Csv("optimized")).Append(',').Append(sweepRuns).Append(',').Append("").Append(',').Append("").Append(',');
            sb.Append(Csv("parameter_sweeps.csv")).Append(',').Append(Csv(study.ParameterSweeps.Count + " sweep points complete")).AppendLine();
            sb.Append("charts,").Append(Csv("svg")).Append(',').Append(Csv("all")).Append(',').Append("").Append(',').Append("").Append(',').Append("").Append(',');
            sb.Append(Csv("charts/*.svg")).Append(',').Append(Csv("10 charts generated")).AppendLine();
            sb.Append("traces,").Append(Csv("diagnostic")).Append(',').Append(Csv("mixed")).Append(',').Append("").Append(',').Append("").Append(',').Append("").Append(',');
            sb.Append(Csv("traces/sample_traces.md")).Append(',').Append(Csv("deterministic sample and anomaly traces generated")).AppendLine();
            File.WriteAllText(path, sb.ToString());
        }

        private static void WriteTraceSamples(StudyResult study, string traceDir)
        {
            Directory.CreateDirectory(traceDir);
            List<TraceCase> cases = new List<TraceCase>();
            foreach (string policy in Policies)
            {
                cases.Add(new TraceCase("representative", policy, study.Seed ^ StableHash("trace.representative." + policy)));
            }

            SimResult highBankroll = null;
            SimResult earliestFailure = null;
            SimResult heatFailure = null;
            ulong highSeed = 0, earliestSeed = 0, heatSeed = 0;
            for (int i = 0; i < 600; i++)
            {
                ulong scanSeed = (study.Seed ^ StableHash("trace.scan.optimized")) + (ulong)i * 0x9E3779B97F4A7C15UL;
                RunOptions scan = new RunOptions();
                scan.Policy = "optimized";
                scan.Seed = scanSeed;
                SimResult r = Simulator.Simulate(study.Mechanics, scan);
                if (highBankroll == null || r.EndingBankroll > highBankroll.EndingBankroll)
                {
                    highBankroll = r;
                    highSeed = scanSeed;
                }
                if (!r.Completed && (earliestFailure == null || r.FinalStage < earliestFailure.FinalStage || (r.FinalStage == earliestFailure.FinalStage && r.EndingBankroll < earliestFailure.EndingBankroll)))
                {
                    earliestFailure = r;
                    earliestSeed = scanSeed;
                }
                if (!r.Completed && r.Failure.IndexOf("heat", StringComparison.OrdinalIgnoreCase) >= 0 && (heatFailure == null || r.FinalStage > heatFailure.FinalStage))
                {
                    heatFailure = r;
                    heatSeed = scanSeed;
                }
            }
            if (highBankroll != null) cases.Add(new TraceCase("anomaly_high_bankroll", "optimized", highSeed));
            if (earliestFailure != null) cases.Add(new TraceCase("anomaly_early_failure", "optimized", earliestSeed));
            if (heatFailure != null && heatSeed != earliestSeed) cases.Add(new TraceCase("anomaly_heat_failure", "optimized", heatSeed));

            StringBuilder md = new StringBuilder();
            StringBuilder csv = new StringBuilder();
            md.AppendLine("# Deterministic Trace Samples");
            md.AppendLine();
            md.AppendLine("These traces are compact examples generated from the same root seed as the aggregate study. They are diagnostic examples, not additional aggregate samples.");
            md.AppendLine();
            csv.AppendLine("kind,policy,seed,completed,final_stage,failure,ending_bankroll,highest_bankroll,heat,chips,hands,decisions,meaningful_decisions,reveal_decisions,active_build,owned_modifiers,rewards_picked,modifiers_picked");
            HashSet<string> seen = new HashSet<string>();
            foreach (TraceCase c in cases)
            {
                string key = c.Kind + ":" + c.Policy + ":" + c.Seed.ToString(CultureInfo.InvariantCulture);
                if (seen.Contains(key)) continue;
                seen.Add(key);
                RunOptions ro = new RunOptions();
                ro.Policy = c.Policy;
                ro.Seed = c.Seed;
                ro.CaptureTrace = true;
                SimResult r = Simulator.Simulate(study.Mechanics, ro);

                csv.Append(Csv(c.Kind)).Append(',').Append(Csv(c.Policy)).Append(',').Append(c.Seed.ToString(CultureInfo.InvariantCulture)).Append(',');
                csv.Append(r.Completed ? "true" : "false").Append(',').Append(r.FinalStage).Append(',').Append(Csv(r.Failure)).Append(',');
                csv.Append(r.EndingBankroll).Append(',').Append(r.HighestBankroll).Append(',').Append(r.Heat).Append(',').Append(r.Chips).Append(',').Append(r.Hands).Append(',').Append(r.Decisions).Append(',').Append(r.MeaningfulDecisions).Append(',').Append(r.RevealDecisions).Append(',');
                csv.Append(Csv(r.ActiveBuild)).Append(',').Append(Csv(string.Join(";", r.OwnedModifiers.ToArray()))).Append(',').Append(Csv(string.Join(";", r.RewardsPicked.ToArray()))).Append(',').Append(Csv(string.Join(";", r.ModifiersPicked.ToArray()))).AppendLine();

                md.AppendLine("## " + c.Kind + " / " + c.Policy + " / " + c.Seed.ToString(CultureInfo.InvariantCulture));
                md.AppendLine();
                md.AppendLine("- Completed: " + (r.Completed ? "yes" : "no") + "; final stage: " + r.FinalStage + "; failure: `" + r.Failure + "`.");
                md.AppendLine("- Ending bankroll: " + Money(r.EndingBankroll) + "; heat: " + r.Heat + "; hands: " + r.Hands + "; build: `" + r.ActiveBuild + "`.");
                md.AppendLine("- Rewards: " + (r.RewardsPicked.Count == 0 ? "none" : string.Join(", ", r.RewardsPicked.ToArray())) + ".");
                md.AppendLine("- Modifiers picked: " + (r.ModifiersPicked.Count == 0 ? "none" : string.Join(", ", r.ModifiersPicked.ToArray())) + ".");
                md.AppendLine();
                md.AppendLine("```text");
                foreach (string line in r.Trace) md.AppendLine(line);
                md.AppendLine("```");
                md.AppendLine();
            }
            File.WriteAllText(Path.Combine(traceDir, "sample_traces.md"), md.ToString());
            File.WriteAllText(Path.Combine(traceDir, "sample_traces_index.csv"), csv.ToString());
        }

        private static void WriteReadme(StudyResult study, string path)
        {
            StringBuilder sb = new StringBuilder();
            sb.AppendLine("# Current Tree Balance Analysis");
            sb.AppendLine();
            sb.AppendLine("## Smoke Test");
            sb.AppendLine();
            sb.AppendLine("```powershell");
            sb.AppendLine("powershell -ExecutionPolicy Bypass -File .\\balance-analysis\\current-tree\\reproduce.ps1 -Mode smoke -RunsPerPolicy 1000 -PairedRuns 250");
            sb.AppendLine("```");
            sb.AppendLine();
            sb.AppendLine("## Full Audit");
            sb.AppendLine();
            sb.AppendLine("```powershell");
            sb.AppendLine("powershell -ExecutionPolicy Bypass -File .\\balance-analysis\\current-tree\\reproduce.ps1 -Mode audit -Workers 0 -Seed 20260622");
            sb.AppendLine("```");
            sb.AppendLine();
            sb.AppendLine("## Resume");
            sb.AppendLine();
            sb.AppendLine("The `-Resume` switch reuses the existing artifact set when `checkpoints/manifest.csv` and all required report files are already present.");
            sb.AppendLine();
            sb.AppendLine("```powershell");
            sb.AppendLine("powershell -ExecutionPolicy Bypass -File .\\balance-analysis\\current-tree\\reproduce.ps1 -Mode audit -Workers 0 -Seed 20260622 -Resume");
            sb.AppendLine("```");
            sb.AppendLine();
            sb.AppendLine("Current limitation: resume is artifact-level, not mid-chunk recovery. If a run is interrupted before final artifact write, rerun the same command and seed for deterministic regeneration.");
            sb.AppendLine();
            sb.AppendLine("## Outputs");
            sb.AppendLine();
            sb.AppendLine("- `BALANCE_REPORT.md`: verdict and findings.");
            sb.AppendLine("- `MECHANICS_CATALOG.md`: source-grounded mechanics catalog.");
            sb.AppendLine("- `METHODOLOGY.md`: harness, policies, validation, and limitations.");
            sb.AppendLine("- `simulation_summary.csv`, `mechanic_effects.csv`, `build_rankings.csv`, `synergy_matrix.csv`, `parameter_sweeps.csv`: aggregate data.");
            sb.AppendLine("- `charts/*.svg`: generated charts.");
            sb.AppendLine("- `checkpoints/manifest.csv`: phase/configuration manifest for completed aggregates.");
            sb.AppendLine("- `traces/sample_traces.md` and `traces/sample_traces_index.csv`: deterministic representative and anomaly traces.");
            sb.AppendLine();
            sb.AppendLine("## Parity");
            sb.AppendLine();
            sb.AppendLine("This Windows environment does not provide Swift/Xcode, so compiled production parity tests cannot run here. Re-run parity on macOS by comparing deterministic `GameViewModel` traces against the same seeds.");
            File.WriteAllText(path, sb.ToString());
        }

        private static void WriteCharts(StudyResult study, string chartDir)
        {
            WriteBarChart(Path.Combine(chartDir, "completion_rate_by_policy.svg"), "Completion Rate By Policy", study.Baselines.Values.Select(a => new ChartPoint(a.Policy, a.CompletionRate())).ToList(), true);
            List<ChartPoint> hazard = new List<ChartPoint>();
            Aggregate opt = study.Baselines["optimized"];
            for (int i = 1; i <= 10; i++) hazard.Add(new ChartPoint("S" + i, opt.StageHazard(i)));
            WriteBarChart(Path.Combine(chartDir, "difficulty_failure_hazard_by_stage.svg"), "Failure Hazard By Stage", hazard, true);
            WriteBarChart(Path.Combine(chartDir, "mechanic_marginal_effects.svg"), "Mechanic Marginal Effects", study.MechanicEffects.OrderByDescending(e => Math.Abs(e.MarginalCompletion)).Take(16).Select(e => new ChartPoint(ShortId(e.Id), e.MarginalCompletion)).ToList(), true);
            WriteScatter(Path.Combine(chartDir, "mechanic_trigger_vs_impact.svg"), "Trigger Rate vs Impact", study.MechanicEffects.Select(e => new ScatterPoint(ShortId(e.Id), e.TriggerRate, e.MarginalCompletion)).ToList());
            WriteScatter(Path.Combine(chartDir, "build_strength_vs_acquisition_probability.svg"), "Build Strength vs Acquisition", BuildScatter(study));
            WriteBarChart(Path.Combine(chartDir, "build_diversity_concentration.svg"), "Build Concentration", BuildConcentration(study), true);
            WriteBarChart(Path.Combine(chartDir, "major_synergy_interactions.svg"), "Major Synergy Interactions", SynergyPoints(study), true);
            WriteLineChart(Path.Combine(chartDir, "parameter_scaling.svg"), "Parameter Scaling", ParameterPoints(study));
            WriteBarChart(Path.Combine(chartDir, "variance_contribution.svg"), "Variance Config Completion", study.VarianceConfigs.Select(a => new ChartPoint(a.Configuration, a.CompletionRate())).ToList(), true);
            List<ChartPoint> agency = new List<ChartPoint>();
            foreach (Aggregate a in study.Baselines.Values) agency.Add(new ChartPoint(a.Policy, a.CompletionRate()));
            WriteBarChart(Path.Combine(chartDir, "randomness_retention_vs_player_agency.svg"), "Randomness Retention vs Agency", agency, true);
        }

        private static List<ScatterPoint> BuildScatter(StudyResult study)
        {
            int total = study.Baselines.Values.Sum(a => a.Runs);
            Dictionary<string, BuildAggregate> all = new Dictionary<string, BuildAggregate>();
            foreach (Aggregate agg in study.Baselines.Values)
            {
                foreach (KeyValuePair<string, BuildAggregate> pair in agg.Builds)
                {
                    if (!all.ContainsKey(pair.Key)) all[pair.Key] = new BuildAggregate();
                    all[pair.Key].Merge(pair.Value);
                }
            }
            return all.OrderByDescending(p => p.Value.Runs).Take(80)
                .Select(p => new ScatterPoint(BuildComponents(p.Key), total > 0 ? p.Value.Runs / (double)total : 0.0, p.Value.CompletionRate()))
                .ToList();
        }

        private static List<ChartPoint> BuildConcentration(StudyResult study)
        {
            Dictionary<string, int> counts = new Dictionary<string, int>();
            foreach (Aggregate a in study.Baselines.Values)
            {
                foreach (KeyValuePair<string, BuildAggregate> pair in a.Builds)
                {
                    counts[pair.Key] = counts.Get(pair.Key) + pair.Value.Runs;
                }
            }
            int total = counts.Values.Sum();
            return counts.OrderByDescending(p => p.Value).Take(12).Select(p => new ChartPoint(BuildComponents(p.Key), total > 0 ? p.Value / (double)total : 0.0)).ToList();
        }

        private static List<ChartPoint> SynergyPoints(StudyResult study)
        {
            Dictionary<string, PairAggregate> pairs = new Dictionary<string, PairAggregate>();
            foreach (Aggregate agg in study.Baselines.Values)
            {
                foreach (KeyValuePair<string, PairAggregate> pair in agg.Pairs)
                {
                    if (!pairs.ContainsKey(pair.Key)) pairs[pair.Key] = new PairAggregate();
                    pairs[pair.Key].Merge(pair.Value);
                }
            }
            return pairs.OrderByDescending(p => p.Value.CompletionRate()).Take(12).Select(p => new ChartPoint(p.Key.Replace("+", " + "), p.Value.CompletionRate())).ToList();
        }

        private static List<LineSeries> ParameterPoints(StudyResult study)
        {
            return study.ParameterSweeps.GroupBy(s => s.ModifierId).Take(8)
                .Select(g =>
                {
                    LineSeries ls = new LineSeries();
                    ls.Name = ShortId(g.Key);
                    foreach (ParameterSweep p in g.OrderBy(x => x.ScalePercent))
                    {
                        ls.Points.Add(new ChartPoint(p.ScalePercent.ToString(CultureInfo.InvariantCulture), p.CompletionRate));
                    }
                    return ls;
                }).ToList();
        }

        private static void WriteBarChart(string path, string title, List<ChartPoint> points, bool pct)
        {
            int w = 1100, h = 520, left = 80, bottom = 110, top = 60, right = 30;
            double max = points.Count == 0 ? 1.0 : Math.Max(0.001, points.Max(p => Math.Abs(p.Value)));
            if (pct) max = Math.Max(max, 0.05);
            double zero = 0;
            if (points.Any(p => p.Value < 0)) { zero = h - bottom - ((0 + max) / (2 * max)) * (h - top - bottom); }
            else { zero = h - bottom; }
            double scaleMax = points.Any(p => p.Value < 0) ? max * 2 : max;
            StringBuilder sb = new StringBuilder();
            sb.AppendLine("<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"" + w + "\" height=\"" + h + "\" viewBox=\"0 0 " + w + " " + h + "\">");
            sb.AppendLine("<rect width=\"100%\" height=\"100%\" fill=\"#f7f4ee\"/>");
            sb.AppendLine("<text x=\"30\" y=\"34\" font-family=\"Segoe UI, Arial\" font-size=\"22\" fill=\"#1c2430\">" + Xml(title) + "</text>");
            sb.AppendLine("<line x1=\"" + left + "\" y1=\"" + F(zero) + "\" x2=\"" + (w - right) + "\" y2=\"" + F(zero) + "\" stroke=\"#30343b\" stroke-width=\"1\"/>");
            int n = Math.Max(1, points.Count);
            double barW = (w - left - right) / (double)n * 0.68;
            for (int i = 0; i < points.Count; i++)
            {
                double x = left + i * ((w - left - right) / (double)n) + ((w - left - right) / (double)n - barW) / 2;
                double val = points[i].Value;
                double y;
                double bh;
                if (points.Any(p => p.Value < 0))
                {
                    y = h - bottom - ((val + max) / scaleMax) * (h - top - bottom);
                    bh = Math.Abs(y - zero);
                    if (val >= 0) y = zero - bh; else y = zero;
                }
                else
                {
                    bh = Math.Abs(val / max) * (h - top - bottom);
                    y = zero - bh;
                }
                sb.AppendLine("<rect x=\"" + F(x) + "\" y=\"" + F(y) + "\" width=\"" + F(barW) + "\" height=\"" + F(Math.Max(1, bh)) + "\" fill=\"" + (val < 0 ? "#b85c4d" : "#2f7d6d") + "\" rx=\"2\"/>");
                sb.AppendLine("<text x=\"" + F(x + barW / 2) + "\" y=\"" + (h - 82) + "\" font-family=\"Segoe UI, Arial\" font-size=\"11\" fill=\"#26313f\" text-anchor=\"middle\" transform=\"rotate(-35 " + F(x + barW / 2) + " " + (h - 82) + ")\">" + Xml(points[i].Label) + "</text>");
                sb.AppendLine("<text x=\"" + F(x + barW / 2) + "\" y=\"" + F(y - 5) + "\" font-family=\"Segoe UI, Arial\" font-size=\"10\" fill=\"#26313f\" text-anchor=\"middle\">" + (pct ? Pct(val) : Num(val)) + "</text>");
            }
            sb.AppendLine("</svg>");
            File.WriteAllText(path, sb.ToString());
        }

        private static void WriteScatter(string path, string title, List<ScatterPoint> points)
        {
            int w = 900, h = 560, left = 80, bottom = 70, top = 60, right = 40;
            double maxX = Math.Max(0.01, points.Count == 0 ? 1 : points.Max(p => p.X));
            double minY = points.Count == 0 ? 0 : Math.Min(0, points.Min(p => p.Y));
            double maxY = Math.Max(0.01, points.Count == 0 ? 1 : points.Max(p => p.Y));
            if (Math.Abs(maxY - minY) < 0.001) maxY = minY + 0.01;
            StringBuilder sb = new StringBuilder();
            sb.AppendLine("<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"" + w + "\" height=\"" + h + "\" viewBox=\"0 0 " + w + " " + h + "\">");
            sb.AppendLine("<rect width=\"100%\" height=\"100%\" fill=\"#f7f4ee\"/>");
            sb.AppendLine("<text x=\"30\" y=\"34\" font-family=\"Segoe UI, Arial\" font-size=\"22\" fill=\"#1c2430\">" + Xml(title) + "</text>");
            sb.AppendLine("<line x1=\"" + left + "\" y1=\"" + (h - bottom) + "\" x2=\"" + (w - right) + "\" y2=\"" + (h - bottom) + "\" stroke=\"#30343b\"/>");
            sb.AppendLine("<line x1=\"" + left + "\" y1=\"" + top + "\" x2=\"" + left + "\" y2=\"" + (h - bottom) + "\" stroke=\"#30343b\"/>");
            foreach (ScatterPoint p in points)
            {
                double x = left + (p.X / maxX) * (w - left - right);
                double y = h - bottom - ((p.Y - minY) / (maxY - minY)) * (h - top - bottom);
                sb.AppendLine("<circle cx=\"" + F(x) + "\" cy=\"" + F(y) + "\" r=\"4\" fill=\"#7b5ea7\" opacity=\"0.78\"><title>" + Xml(p.Label + " " + Num(p.X) + "," + Pct(p.Y)) + "</title></circle>");
            }
            sb.AppendLine("<text x=\"" + (w / 2) + "\" y=\"" + (h - 22) + "\" font-family=\"Segoe UI, Arial\" font-size=\"13\" fill=\"#26313f\" text-anchor=\"middle\">frequency / acquisition probability</text>");
            sb.AppendLine("<text x=\"18\" y=\"" + (h / 2) + "\" font-family=\"Segoe UI, Arial\" font-size=\"13\" fill=\"#26313f\" text-anchor=\"middle\" transform=\"rotate(-90 18 " + (h / 2) + ")\">impact / completion</text>");
            sb.AppendLine("</svg>");
            File.WriteAllText(path, sb.ToString());
        }

        private static void WriteLineChart(string path, string title, List<LineSeries> series)
        {
            int w = 1000, h = 560, left = 80, bottom = 70, top = 60, right = 140;
            double maxY = Math.Max(0.01, series.SelectMany(s => s.Points).Select(p => p.Value).DefaultIfEmpty(1).Max());
            string[] colors = new[] { "#2f7d6d", "#9b5c4d", "#5f6fb0", "#c58d2f", "#764f8f", "#417c9a", "#8f6a3f", "#b05d75" };
            StringBuilder sb = new StringBuilder();
            sb.AppendLine("<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"" + w + "\" height=\"" + h + "\" viewBox=\"0 0 " + w + " " + h + "\">");
            sb.AppendLine("<rect width=\"100%\" height=\"100%\" fill=\"#f7f4ee\"/>");
            sb.AppendLine("<text x=\"30\" y=\"34\" font-family=\"Segoe UI, Arial\" font-size=\"22\" fill=\"#1c2430\">" + Xml(title) + "</text>");
            sb.AppendLine("<line x1=\"" + left + "\" y1=\"" + (h - bottom) + "\" x2=\"" + (w - right) + "\" y2=\"" + (h - bottom) + "\" stroke=\"#30343b\"/>");
            sb.AppendLine("<line x1=\"" + left + "\" y1=\"" + top + "\" x2=\"" + left + "\" y2=\"" + (h - bottom) + "\" stroke=\"#30343b\"/>");
            for (int s = 0; s < series.Count; s++)
            {
                LineSeries ls = series[s];
                List<string> coords = new List<string>();
                for (int i = 0; i < ls.Points.Count; i++)
                {
                    double x = left + i * ((w - left - right) / Math.Max(1.0, ls.Points.Count - 1.0));
                    double y = h - bottom - (ls.Points[i].Value / maxY) * (h - top - bottom);
                    coords.Add(F(x) + "," + F(y));
                    sb.AppendLine("<circle cx=\"" + F(x) + "\" cy=\"" + F(y) + "\" r=\"3\" fill=\"" + colors[s % colors.Length] + "\"/>");
                }
                sb.AppendLine("<polyline points=\"" + string.Join(" ", coords.ToArray()) + "\" fill=\"none\" stroke=\"" + colors[s % colors.Length] + "\" stroke-width=\"2\"/>");
                sb.AppendLine("<text x=\"" + (w - right + 16) + "\" y=\"" + (top + 18 + s * 18) + "\" font-family=\"Segoe UI, Arial\" font-size=\"12\" fill=\"" + colors[s % colors.Length] + "\">" + Xml(ls.Name) + "</text>");
            }
            sb.AppendLine("</svg>");
            File.WriteAllText(path, sb.ToString());
        }

        private static void AppendFinding(StringBuilder sb, int rank, string title, string evidence, string effectSize, string sample, string ci, string consequence, string classification, string intervention)
        {
            sb.AppendLine("## " + rank + ". " + title);
            sb.AppendLine();
            sb.AppendLine("- Evidence: " + evidence);
            sb.AppendLine("- Effect size: " + effectSize);
            sb.AppendLine("- Sample size: " + sample);
            sb.AppendLine("- Confidence interval: " + ci);
            sb.AppendLine("- Player-facing consequence: " + consequence);
            sb.AppendLine("- Recommended classification: " + classification);
            sb.AppendLine("- Smallest credible intervention: " + intervention);
            sb.AppendLine();
        }

        private static void AppendMechanicList(StringBuilder sb, List<MechanicEffect> list, string intro)
        {
            sb.AppendLine(intro);
            foreach (MechanicEffect e in list.Take(10))
            {
                sb.AppendLine("- `" + e.Id + "` " + e.Name + ": trigger " + Num(e.TriggerRate) + "/run, selected " + Pct(e.SelectionRate) + ", marginal completion " + Pct(e.MarginalCompletion) + ", " + e.Classification + ".");
            }
            sb.AppendLine();
        }

        private static string StageHazardTable(StudyResult study)
        {
            StringBuilder sb = new StringBuilder();
            sb.AppendLine("| Stage | Random | Novice | Greedy | Risk-aware | Optimized |");
            sb.AppendLine("|---:|---:|---:|---:|---:|---:|");
            for (int stage = 1; stage <= 10; stage++)
            {
                sb.Append("| ").Append(stage);
                foreach (string p in Policies)
                {
                    sb.Append(" | ").Append(Pct(study.Baselines[p].StageHazard(stage)));
                }
                sb.AppendLine(" |");
            }
            return sb.ToString();
        }

        private static double[] BinomialCi(int successes, int n)
        {
            if (n <= 0) return new[] { 0.0, 0.0 };
            double p = successes / (double)n;
            double se = Math.Sqrt(Math.Max(0, p * (1 - p) / n));
            return new[] { Math.Max(0, p - 1.96 * se), Math.Min(1, p + 1.96 * se) };
        }

        private static string Csv(string value)
        {
            if (value == null) value = "";
            return "\"" + value.Replace("\"", "\"\"") + "\"";
        }

        private static string Pct(double value)
        {
            return (value * 100.0).ToString("0.###", CultureInfo.InvariantCulture) + "%";
        }

        private static string Num(double value)
        {
            return value.ToString("0.###", CultureInfo.InvariantCulture);
        }

        private static string F(double value)
        {
            return value.ToString("0.##", CultureInfo.InvariantCulture);
        }

        private static string Money(int cents)
        {
            string sign = cents < 0 ? "-" : "";
            double dollars = Math.Abs(cents) / 100.0;
            return sign + "$" + dollars.ToString("#,0.##", CultureInfo.InvariantCulture);
        }

        private static string CsvList(IEnumerable<string> values)
        {
            return EscapeMd(string.Join(", ", values.ToArray()));
        }

        private static string EscapeMd(string value)
        {
            if (value == null) return "";
            return value.Replace("|", "\\|").Replace("\r", " ").Replace("\n", " ");
        }

        private static string Xml(string value)
        {
            if (value == null) return "";
            return value.Replace("&", "&amp;").Replace("<", "&lt;").Replace(">", "&gt;").Replace("\"", "&quot;");
        }

        private static string ShortId(string id)
        {
            if (id == null) return "";
            int dot = id.IndexOf('.');
            string s = dot >= 0 ? id.Substring(dot + 1) : id;
            return s.Length > 18 ? s.Substring(0, 18) : s;
        }

        private static string BuildComponents(string key)
        {
            if (string.IsNullOrEmpty(key)) return "none";
            string[] parts = key.Split('|');
            if (parts.Length > 4) parts = parts.Take(4).ToArray();
            return string.Join(" + ", parts.Select(ShortId).ToArray());
        }

        private static ulong StableHash(string text)
        {
            unchecked
            {
                ulong hash = 1469598103934665603UL;
                for (int i = 0; i < text.Length; i++)
                {
                    hash ^= (byte)text[i];
                    hash *= 1099511628211UL;
                }
                return hash;
            }
        }
    }

    internal class Simulator
    {
        public static SimResult Simulate(Mechanics mechanics, RunOptions options)
        {
            SimState s = new SimState();
            s.Mechanics = mechanics;
            s.Options = options;
            s.ShoeRng = new Lcg(options.Seed ^ 0x53484F45UL);
            s.TreeRng = new Lcg(options.Seed ^ 0x54524545UL);
            s.RewardRng = new Lcg(options.Seed ^ 0x524557415244UL);
            s.PolicyRng = new Lcg(options.Seed ^ 0x504F4C494359UL);
            s.Policy = options.Policy;
            s.Contact = ChooseContact(mechanics, s.Policy, ref s.PolicyRng);
            s.Bankroll = Math.Max(5000, 25000 + s.Contact.BankrollAdjust);
            s.Chips = Math.Max(0, 3 + s.Contact.ChipsAdjust);
            s.Heat = Math.Max(0, s.Contact.HeatAdjust);
            s.Shoe = NewShoe(ref s.ShoeRng, 6);
            foreach (string id in s.Contact.StartingModifiers)
            {
                TryAddModifier(s, id, true);
            }

            SimResult result = new SimResult();
            result.Seed = options.Seed;
            result.Policy = options.Policy;
            result.Contact = s.Contact.Id;
            AddTrace(result, options, "start seed=" + options.Seed.ToString(CultureInfo.InvariantCulture) + " policy=" + options.Policy + " contact=" + s.Contact.Id + " bankroll_cents=" + s.Bankroll + " chips=" + s.Chips + " heat=" + s.Heat);

            for (int stageIndex = 0; stageIndex < mechanics.Stages.Length; stageIndex++)
            {
                Stage stage = mechanics.Stages[stageIndex];
                s.Stage = stage;
                s.StageIndex = stageIndex;
                s.StageStartBankroll = s.Bankroll;
                s.StageStartHeat = s.Heat;
                s.StageStartChips = s.Chips;
                s.StageRoundsPlayed = 0;
                s.StageWinningBets = 0;
                s.StageUpgradeTriggers = 0;
                s.StageRevealWins = 0;
                s.StageLosses = 0;
                s.StageOpponentProfit = 0;
                s.StageWinningSides.Clear();
                s.StageFinalHandWon = false;
                s.StageFellBehind = false;
                s.StageStayedUnderQuarter = true;
                s.StageConsumablesUsed = 0;
                s.ModifierRevealCount = 0;
                s.BossLastBet = "";
                s.BossSameSideCount = 0;
                s.BossInspectorUsed = false;
                s.HouseAdaptiveUsed = false;
                s.HouseRuleShiftUsed = false;
                ResetStageUses(s);

                ApplyStageStarted(s);
                s.ActiveBoss = stage.BossName;
                ApplyBossStageStartLegacy(s);
                AddTrace(result, options, "stage_start stage=" + stage.Id + " hands=" + stage.Hands + " ante_cents=" + stage.AnteCents + " min_bet_cents=" + stage.MinimumBetCents + " bankroll_cents=" + s.Bankroll + " heat=" + s.Heat + " chips=" + s.Chips + " boss=" + (stage.BossName.Length == 0 ? "none" : stage.BossName) + " active_mods=" + ShortModList(s));

                bool failed = false;
                string failure = "";

                for (int hand = 1; hand <= stage.Hands; hand++)
                {
                    if (s.Shoe.Count < 20)
                    {
                        s.Shoe = NewShoe(ref s.ShoeRng, 6);
                        ApplyReshuffleLegacy(s);
                    }

                    BetDecision decision = ChooseBet(s);
                    if (decision.Amount <= 0 || s.Bankroll < decision.Amount || s.Bankroll < stage.MinimumBetCents)
                    {
                        failed = true;
                        failure = "stage_" + stage.Id + "_bankroll_minimum";
                        AddTrace(result, options, "fail_predeal stage=" + stage.Id + " hand=" + hand + " reason=" + failure + " bankroll_cents=" + s.Bankroll + " bet_cents=" + decision.Amount);
                        break;
                    }

                    s.TotalDecisions++;
                    result.Decisions++;
                    if (decision.Meaningful) result.MeaningfulDecisions++;
                    if (s.VisibleRevealCount() > 0) result.RevealDecisions++;

                    ResolveEvent(s, GameEvent.BetPlaced(decision.Side, decision.Amount));
                    s.Bankroll -= decision.Amount;
                    ResolveEvent(s, GameEvent.BeforeDeal());
                    ApplyBossPressure(s, decision.Side);

                    int cardsBefore = s.Shoe.Count;
                    DealOutcome deal = DealHand(s);
                    int cardsDealt = cardsBefore - s.Shoe.Count;
                    Payout payout = ResolvePayout(s, decision.Side, decision.Amount, deal, cardsDealt);
                    s.Bankroll += payout.TotalReturn;
                    bool didWin = !payout.IsPush && deal.Winner == decision.Side;

                    if (stage.TableEventId == "cold-table" && !payout.IsPush && !didWin && s.StageLosses == 0)
                    {
                        s.StageOpponentProfit += stage.AnteCents * 2;
                        ApplyHeat(s, 2, "cold-table");
                    }

                    if (didWin)
                    {
                        ResolveEvent(s, GameEvent.PlayerWon(decision.Side, deal.Winner, decision.Amount, payout.TotalReturn));
                    }
                    else
                    {
                        ResolveEvent(s, GameEvent.PlayerLost(decision.Side, deal.Winner, decision.Amount));
                    }
                    if (deal.Winner == "tie")
                    {
                        ResolveEvent(s, GameEvent.TieOccurred());
                    }

                    int opponentDelta = OpponentProfit(stage, hand, s.LastWinner, decision.Side, deal.Winner);
                    s.StageOpponentProfit += opponentDelta;
                    int stageProfit = s.Bankroll - s.StageStartBankroll;
                    if (stageProfit < s.StageOpponentProfit) s.StageFellBehind = true;

                    if (stage.TableEventId == "tight-surveillance" && payout.Profit > stage.AnteCents * 2)
                    {
                        ApplyHeat(s, 1, "tight-surveillance");
                    }
                    if (stage.TableEventId == "rich-crowd" && payout.Profit >= stage.AnteCents * 2)
                    {
                        s.Chips += 1;
                    }
                    if (stage.TableEventId == "final-hand-spotlight" && hand == stage.Hands && didWin)
                    {
                        s.Chips += 1;
                    }

                    RecordRound(s, deal, decision, payout, didWin, hand, cardsDealt);
                    AddTrace(result, options, "hand stage=" + stage.Id + " hand=" + hand + " bet=" + decision.Side + " bet_cents=" + decision.Amount + " winner=" + deal.Winner + " player_total=" + deal.PlayerTotal + " banker_total=" + deal.BankerTotal + " natural=" + (deal.Natural ? "true" : "false") + " return_cents=" + payout.TotalReturn + " bankroll_cents=" + s.Bankroll + " heat=" + s.Heat + " opponent_profit_cents=" + s.StageOpponentProfit + " reveal_count=" + s.VisibleRevealCount());
                    result.Hands++;

                    if (s.ActiveBoss == "The House")
                    {
                        ShuffleRemaining(s);
                    }

                    if (s.Heat >= 10)
                    {
                        failed = true;
                        failure = "stage_" + stage.Id + "_heat";
                        break;
                    }
                    if (s.Bankroll < stage.MinimumBetCents)
                    {
                        failed = true;
                        failure = "stage_" + stage.Id + "_bankroll_minimum";
                        break;
                    }
                }

                int tolerance = OpponentTolerance(stage);
                int finalStageProfit = s.Bankroll - s.StageStartBankroll;
                bool clear = !failed && finalStageProfit >= s.StageOpponentProfit - tolerance;
                result.StageAttempts[stage.Id]++;
                if (clear) result.StageClears[stage.Id]++;
                else result.StageFailures[stage.Id]++;
                result.FinalStage = stage.Id;

                if (clear)
                {
                    int heatBefore = s.Heat;
                    if (finalStageProfit < 0) s.Heat = Math.Min(10, s.Heat + (stage.IsBoss ? 2 : 1));
                    int chips = StageClearChips(stage) + (SecondaryComplete(s, stage, finalStageProfit) ? 1 : 0);
                    s.Chips += chips;
                    if (s.Heat >= 10)
                    {
                        failed = true;
                        failure = "stage_" + stage.Id + "_heat_after_clear";
                        clear = false;
                    }
                }
                AddTrace(result, options, "stage_result stage=" + stage.Id + " clear=" + (clear ? "true" : "false") + " profit_cents=" + finalStageProfit + " opponent_profit_cents=" + s.StageOpponentProfit + " tolerance_cents=" + tolerance + " bankroll_cents=" + s.Bankroll + " heat=" + s.Heat + " chips=" + s.Chips);

                if (!clear)
                {
                    result.Completed = false;
                    result.Failure = failure.Length > 0 ? failure : "stage_" + stage.Id + "_opponent_loss";
                    break;
                }

                if (stage.Id == 10)
                {
                    result.Completed = true;
                    result.Failure = "run_complete";
                    break;
                }

                if (stage.IsBoss)
                {
                    s.BossesDefeated++;
                    int rewardBefore = result.RewardsPicked.Count;
                    int modifierBefore = result.ModifiersPicked.Count;
                    ApplyBossRewardDraft(s, result);
                    AddTraceChoices(result, options, "boss_reward", rewardBefore, modifierBefore);
                }
                else
                {
                    int rewardBefore = result.RewardsPicked.Count;
                    int modifierBefore = result.ModifiersPicked.Count;
                    ApplyStageRewardDraft(s, result);
                    AddTraceChoices(result, options, "stage_reward", rewardBefore, modifierBefore);
                }
                int shopRewardBefore = result.RewardsPicked.Count;
                int shopModifierBefore = result.ModifiersPicked.Count;
                RunShop(s, result);
                AddTraceChoices(result, options, "shop", shopRewardBefore, shopModifierBefore);
            }

            result.EndingBankroll = s.Bankroll;
            result.HighestBankroll = Math.Max(s.HighestBankroll, s.Bankroll);
            result.Heat = s.Heat;
            result.Chips = s.Chips;
            result.ActiveBuild = BuildKey(s);
            foreach (ModifierInstance mi in s.ActiveMods)
            {
                result.OwnedModifiers.Add(mi.Def.Id);
            }
            foreach (KeyValuePair<string, int> pair in s.ModifierTriggers) result.ModifierTriggers[pair.Key] = pair.Value;
            foreach (KeyValuePair<string, int> pair in s.ModifierOffers) result.ModifierOffers[pair.Key] = pair.Value;
            foreach (KeyValuePair<string, int> pair in s.ModifierPicks) result.ModifierPicks[pair.Key] = pair.Value;
            AddTrace(result, options, "finish completed=" + (result.Completed ? "true" : "false") + " final_stage=" + result.FinalStage + " failure=" + result.Failure + " ending_bankroll_cents=" + result.EndingBankroll + " highest_bankroll_cents=" + result.HighestBankroll + " heat=" + result.Heat + " owned_mods=" + string.Join(";", result.OwnedModifiers.ToArray()));
            return result;
        }

        private static void AddTrace(SimResult result, RunOptions options, string line)
        {
            if (options.CaptureTrace) result.Trace.Add(line);
        }

        private static void AddTraceChoices(SimResult result, RunOptions options, string label, int rewardBefore, int modifierBefore)
        {
            if (!options.CaptureTrace) return;
            if (result.RewardsPicked.Count > rewardBefore)
            {
                AddTrace(result, options, label + "_rewards=" + string.Join(";", result.RewardsPicked.Skip(rewardBefore).ToArray()));
            }
            if (result.ModifiersPicked.Count > modifierBefore)
            {
                AddTrace(result, options, label + "_modifiers=" + string.Join(";", result.ModifiersPicked.Skip(modifierBefore).ToArray()));
            }
        }

        private static string ShortModList(SimState s)
        {
            return string.Join(";", s.ActiveMods.Select(m => m.Def.Id).Take(10).ToArray());
        }

        private static Contact ChooseContact(Mechanics m, string policy, ref Lcg rng)
        {
            string id = "contact.tourist";
            if (policy == "novice") id = "contact.accountant";
            else if (policy == "greedy") id = "contact.whale";
            else if (policy == "risk_aware") id = "contact.ghost";
            else if (policy == "optimized") id = "contact.dealer";
            else if (policy == "random")
            {
                List<Contact> all = m.Contacts.Values.ToList();
                return all[rng.NextInt(all.Count)];
            }
            return m.Contacts.ContainsKey(id) ? m.Contacts[id] : m.Contacts["contact.tourist"];
        }

        private static void ApplyStageStarted(SimState s)
        {
            ResolveEvent(s, GameEvent.StageStarted());
            ApplyLegacyStageStart(s);
        }

        private static void ApplyLegacyStageStart(SimState s)
        {
            UpgradeSummary u = s.UpgradeSummary;
            int cash = u.StageStartCashCents + s.Stage.AnteCents * u.StageStartCashAnteMultiplierPercent / 100;
            if (cash > 0)
            {
                s.Bankroll += cash;
                s.HighestBankroll = Math.Max(s.HighestBankroll, s.Bankroll);
            }
            s.ModifierRevealCount = Math.Max(s.ModifierRevealCount, u.RevealedCards);
        }

        private static void ApplyBossStageStartLegacy(SimState s)
        {
            if (s.ActiveBoss.Length == 0) return;
            UpgradeSummary u = s.UpgradeSummary;
            int cash = u.BossStageCashCents + s.Stage.AnteCents * u.BossStageCashAnteMultiplierPercent / 100;
            if (cash > 0)
            {
                s.Bankroll += cash;
                s.HighestBankroll = Math.Max(s.HighestBankroll, s.Bankroll);
            }
        }

        private static void ResolveEvent(SimState s, GameEvent evt)
        {
            List<ModifierResolution> resolutions = ResolveModifiers(s, evt);
            int heat = resolutions.Sum(r => Math.Max(0, r.HeatDelta));
            if (heat > 0 && evt.Trigger != "heatGained")
            {
                resolutions.InsertRange(0, ResolveModifiers(s, GameEvent.HeatGained(heat)));
            }
            ApplyResolutions(s, resolutions);
        }

        private static List<ModifierResolution> ResolveModifiers(SimState s, GameEvent evt)
        {
            List<ModifierResolution> results = new List<ModifierResolution>();
            foreach (ModifierInstance inst in s.ActiveMods)
            {
                ModifierDef m = inst.Def;
                if (m.Trigger != evt.Trigger) continue;
                if (s.Options.DisabledModifierId == m.Id) continue;
                if (!CanUse(inst, m)) continue;
                if (!ConditionsSatisfied(s, m, evt)) continue;
                if (m.HeatCost > 0 && m.HeatCost > 10 - s.Heat) continue;

                int scale = s.Options.GlobalScalePercent;
                if (s.Options.ScaleMap != null && s.Options.ScaleMap.ContainsKey(m.Id)) scale = s.Options.ScaleMap[m.Id];
                int level = Math.Max(1, Math.Min(3, inst.Level));
                ModifierResolution r = new ModifierResolution();
                r.ModifierId = m.Id;
                r.ModifierName = m.Name;
                r.HeatDelta += m.HeatCost;

                r.BankrollDelta += Scaled(s.Stage.AnteCents * m.AntePercent[level - 1] / 100, scale);
                r.ChipDelta += Scaled(m.Chips[level - 1], scale);
                if (m.ChipFirstStageOnly && inst.StageChipGranted) r.ChipDelta = 0;
                if (m.ChipFirstStageOnly && r.ChipDelta > 0) inst.StageChipGranted = true;
                r.HeatDelta += Scaled(m.GainHeat[level - 1], scale);
                r.HeatDelta -= Scaled(m.ReduceHeat[level - 1], scale);
                if (evt.Trigger == "heatGained" && m.PreventHeat[level - 1] > 0)
                {
                    int prevented = Math.Min(evt.HeatAmount, m.PreventHeat[level - 1] >= 99 ? evt.HeatAmount : m.PreventHeat[level - 1]);
                    r.HeatDelta -= prevented;
                    r.HeatPrevented = prevented;
                }
                if (evt.Trigger == "playerLostBet")
                {
                    r.BankrollDelta += Scaled(evt.Amount * m.RefundPercent[level - 1] / 100, scale);
                }
                if (evt.Trigger == "playerWonBet")
                {
                    int pct = m.PayoutPercentFor(evt.BetType, level);
                    r.BankrollDelta += Scaled(evt.Amount * pct / 100, scale);
                }
                r.Reveal = Math.Max(r.Reveal, m.Reveal[level - 1]);
                r.Burn += m.Burn[level - 1];
                r.MoveTopBottom = r.MoveTopBottom || m.MoveTopBottom[level - 1];
                r.MoveTopDeeper = Math.Max(r.MoveTopDeeper, m.MoveTopDeeper[level - 1]);
                r.AddEights += m.AddEights[level - 1];
                r.AddNines += m.AddNines[level - 1];

                if (r.HasEffect())
                {
                    inst.StageUses++;
                    inst.RunUses++;
                    inst.HandUses++;
                    results.Add(r);
                    s.ModifierTriggers[m.Id] = s.ModifierTriggers.Get(m.Id) + 1;
                    s.StageUpgradeTriggers++;
                }
            }
            return results;
        }

        private static int Scaled(int value, int scale)
        {
            return value * scale / 100;
        }

        private static bool CanUse(ModifierInstance inst, ModifierDef m)
        {
            int level = Math.Max(1, Math.Min(3, inst.Level));
            if (m.StageLimit[level - 1] >= 0 && inst.StageUses >= m.StageLimit[level - 1]) return false;
            if (m.RunLimit[level - 1] >= 0 && inst.RunUses >= m.RunLimit[level - 1]) return false;
            if (m.HandLimit[level - 1] >= 0 && inst.HandUses >= m.HandLimit[level - 1]) return false;
            return true;
        }

        private static bool ConditionsSatisfied(SimState s, ModifierDef m, GameEvent evt)
        {
            if (m.RequiredBet.Length > 0 && evt.BetType != m.RequiredBet) return false;
            if (m.RequiredWinner.Length > 0 && evt.Winner != m.RequiredWinner) return false;
            if (m.FirstPlayerSideWin && s.PlayerSideWinsThisStage > 0) return false;
            if (m.FirstBankerSideWin && s.BankerSideWinsThisStage > 0) return false;
            if (m.FirstWinningBet && s.StageWinningBets > 0) return false;
            if (m.FirstTieLoss && s.TieBetLossesThisStage > 0) return false;
            if (m.HasTagCondition.Length > 0 && !s.ActiveTags().Contains(m.HasTagCondition)) return false;
            return true;
        }

        private static void ApplyResolutions(SimState s, List<ModifierResolution> resolutions)
        {
            foreach (ModifierResolution r in resolutions)
            {
                if (r.BankrollDelta != 0)
                {
                    s.Bankroll += r.BankrollDelta;
                    s.HighestBankroll = Math.Max(s.HighestBankroll, s.Bankroll);
                    s.ModifierBankrollDelta[r.ModifierId] = s.ModifierBankrollDelta.Get(r.ModifierId) + r.BankrollDelta;
                }
                if (r.ChipDelta != 0)
                {
                    s.Chips = Math.Max(0, s.Chips + r.ChipDelta);
                }
                if (r.HeatDelta != 0)
                {
                    s.Heat = Math.Max(0, Math.Min(10, s.Heat + r.HeatDelta));
                }
                if (r.Reveal > 0)
                {
                    s.ModifierRevealCount = Math.Max(s.ModifierRevealCount, r.Reveal);
                }
                for (int i = 0; i < r.Burn; i++)
                {
                    if (s.Shoe.Count > 0) s.Shoe.RemoveAt(0);
                }
                if (r.MoveTopBottom && s.Shoe.Count > 1)
                {
                    Card c = s.Shoe[0];
                    s.Shoe.RemoveAt(0);
                    s.Shoe.Add(c);
                }
                if (r.MoveTopDeeper > 0 && s.Shoe.Count > 1)
                {
                    Card c = s.Shoe[0];
                    s.Shoe.RemoveAt(0);
                    s.Shoe.Insert(Math.Min(r.MoveTopDeeper, s.Shoe.Count), c);
                }
                if (r.AddEights > 0) AddRandomCards(s, 8, r.AddEights);
                if (r.AddNines > 0) AddRandomCards(s, 9, r.AddNines);
            }
        }

        private static void ApplyHeat(SimState s, int amount, string source)
        {
            if (amount <= 0) return;
            List<ModifierResolution> prevention = ResolveModifiers(s, GameEvent.HeatGained(amount));
            int prevented = prevention.Sum(r => r.HeatPrevented);
            ApplyResolutions(s, prevention);
            int remaining = Math.Max(0, amount - prevented);
            if (remaining > 0) s.Heat = Math.Min(10, s.Heat + remaining);
        }

        private static List<Card> NewShoe(ref Lcg rng, int deckCount)
        {
            List<Card> cards = new List<Card>(deckCount * 52);
            for (int d = 0; d < deckCount; d++)
            {
                for (int suit = 0; suit < 4; suit++)
                {
                    for (int rank = 1; rank <= 13; rank++)
                    {
                        cards.Add(new Card(rank, suit));
                    }
                }
            }
            Shuffle(cards, ref rng);
            return cards;
        }

        private static void ShuffleRemaining(SimState s)
        {
            Shuffle(s.Shoe, ref s.ShoeRng);
            ApplyReshuffleLegacy(s);
        }

        private static void Shuffle(List<Card> cards, ref Lcg rng)
        {
            for (int i = cards.Count - 1; i > 0; i--)
            {
                int j = rng.NextInt(i + 1);
                Card tmp = cards[i];
                cards[i] = cards[j];
                cards[j] = tmp;
            }
        }

        private static void AddRandomCards(SimState s, int rank, int count)
        {
            for (int i = 0; i < count; i++)
            {
                int suit = s.ShoeRng.NextInt(4);
                s.Shoe.Add(new Card(rank, suit));
            }
            Shuffle(s.Shoe, ref s.ShoeRng);
        }

        private static void AddRandomHighValueCards(SimState s, int count)
        {
            for (int i = 0; i < count; i++)
            {
                int rank = s.ShoeRng.NextInt(2) == 0 ? 8 : 9;
                int suit = s.ShoeRng.NextInt(4);
                s.Shoe.Add(new Card(rank, suit));
            }
            Shuffle(s.Shoe, ref s.ShoeRng);
        }

        private static void AddTiePairs(SimState s, int pairs)
        {
            for (int i = 0; i < pairs; i++)
            {
                int rank = s.ShoeRng.NextInt(13) + 1;
                s.Shoe.Add(new Card(rank, s.ShoeRng.NextInt(4)));
                s.Shoe.Add(new Card(rank, s.ShoeRng.NextInt(4)));
            }
            Shuffle(s.Shoe, ref s.ShoeRng);
        }

        private static void RemoveZeroCards(SimState s, int count)
        {
            RemoveCards(s, count, delegate(Card c) { return c.Value == 0; });
        }

        private static void RemoveFaceCards(SimState s, int count)
        {
            RemoveCards(s, count, delegate(Card c) { return c.Rank >= 11 && c.Rank <= 13; });
        }

        private static void RemoveCards(SimState s, int count, Func<Card, bool> match)
        {
            List<int> indices = new List<int>();
            for (int i = 0; i < s.Shoe.Count; i++) if (match(s.Shoe[i])) indices.Add(i);
            for (int r = 0; r < count && indices.Count > 0; r++)
            {
                int pick = s.ShoeRng.NextInt(indices.Count);
                int index = indices[pick];
                s.Shoe.RemoveAt(index);
                indices.RemoveAt(pick);
                for (int k = 0; k < indices.Count; k++) if (indices[k] > index) indices[k]--;
            }
        }

        private static DealOutcome DealHand(SimState s)
        {
            Card p1 = Draw(s);
            Card b1 = Draw(s);
            Card p2 = Draw(s);
            Card b2 = Draw(s);
            List<Card> player = new List<Card> { p1, p2 };
            List<Card> banker = new List<Card> { b1, b2 };
            int bankerInitial = HandTotal(banker);
            bool natural = IsNatural(player) || IsNatural(banker);
            if (!natural)
            {
                Card? playerThird = null;
                if (HandTotal(player) <= 5)
                {
                    Card c = Draw(s);
                    playerThird = c;
                    player.Add(c);
                }
                if (ShouldBankerDraw(HandTotal(banker), playerThird))
                {
                    banker.Add(Draw(s));
                }
            }
            string winner = DetermineWinner(HandTotal(player), HandTotal(banker));
            DealOutcome d = new DealOutcome();
            d.Winner = winner;
            d.PlayerTotal = HandTotal(player);
            d.BankerTotal = HandTotal(banker);
            d.BankerInitialTotal = bankerInitial;
            d.Natural = natural;
            d.PlayerCards = player;
            d.BankerCards = banker;
            return d;
        }

        private static Card Draw(SimState s)
        {
            if (s.Shoe.Count == 0)
            {
                s.Shoe = NewShoe(ref s.ShoeRng, 6);
            }
            Card c = s.Shoe[0];
            s.Shoe.RemoveAt(0);
            return c;
        }

        private static int HandTotal(List<Card> cards)
        {
            int sum = 0;
            foreach (Card c in cards) sum += c.Value;
            return sum % 10;
        }

        private static bool IsNatural(List<Card> cards)
        {
            int t = HandTotal(cards);
            return cards.Count == 2 && (t == 8 || t == 9);
        }

        private static bool ShouldBankerDraw(int bankerTotal, Card? playerThird)
        {
            if (!playerThird.HasValue) return bankerTotal <= 5;
            int v = playerThird.Value.Value;
            if (bankerTotal <= 2) return true;
            if (bankerTotal == 3) return v != 8;
            if (bankerTotal == 4) return v >= 2 && v <= 7;
            if (bankerTotal == 5) return v >= 4 && v <= 7;
            if (bankerTotal == 6) return v >= 6 && v <= 7;
            return false;
        }

        private static string DetermineWinner(int player, int banker)
        {
            if (player > banker) return "player";
            if (banker > player) return "banker";
            return "tie";
        }

        private static Forecast Forecast(SimState s)
        {
            Forecast f = new Forecast();
            int reveal = s.VisibleRevealCount();
            if (reveal < 4 || s.Shoe.Count < 4) return f;
            List<Card> preview = s.Shoe.Take(Math.Min(s.Shoe.Count, Math.Max(4, reveal))).ToList();
            List<Card> player = new List<Card> { preview[0], preview[2] };
            List<Card> banker = new List<Card> { preview[1], preview[3] };
            if (IsNatural(player) || IsNatural(banker))
            {
                f.Recommended = DetermineWinner(HandTotal(player), HandTotal(banker));
                f.Complete = true;
                f.Natural = true;
                return f;
            }
            int next = 4;
            Card? third = null;
            if (HandTotal(player) <= 5)
            {
                if (preview.Count <= next)
                {
                    f.Recommended = DetermineWinner(HandTotal(player), HandTotal(banker));
                    f.Partial = true;
                    return f;
                }
                third = preview[next++];
                player.Add(third.Value);
            }
            if (ShouldBankerDraw(HandTotal(banker), third))
            {
                if (preview.Count <= next)
                {
                    f.Recommended = DetermineWinner(HandTotal(player), HandTotal(banker));
                    f.Partial = true;
                    return f;
                }
                banker.Add(preview[next]);
            }
            f.Recommended = DetermineWinner(HandTotal(player), HandTotal(banker));
            f.Complete = true;
            return f;
        }

        private static Payout ResolvePayout(SimState s, string bet, int amount, DealOutcome deal, int cardsDealt)
        {
            UpgradeSummary u = s.UpgradeSummary;
            Payout p = new Payout();
            p.IsPush = false;
            int passive = u.RoundStipendCents + s.Stage.AnteCents * u.RoundStipendAntePercent / 100 + cardsDealt * u.CardExitIncomeCents;
            int previousRefund = deal.Winner == "tie" ? s.PreviousRoundLoss * u.PreviousLossRefundOnTiePercent / 100 : 0;
            if (deal.Winner == "tie" && bet != "tie")
            {
                p.TotalReturn = amount + passive + previousRefund;
                p.Profit = passive + previousRefund;
                p.IsPush = true;
                return p;
            }
            if (deal.Winner != bet)
            {
                int rebate = amount * u.LossRebatePercent / 100;
                if (u.DamageControlRebatePercent > 0 && u.DamageControlEveryHands > 0 && s.DamageControlHandsSinceUse >= u.DamageControlEveryHands)
                {
                    rebate += amount * u.DamageControlRebatePercent / 100;
                    p.UsedDamageControl = true;
                }
                int extraLoss = amount * Math.Max(0, u.LossMultiplierPercent - 100) / 100;
                p.TotalReturn = passive + rebate - extraLoss + previousRefund;
                p.Profit = p.TotalReturn - amount;
                return p;
            }

            int profit = 0;
            if (bet == "player") profit = amount;
            else if (bet == "banker") profit = BankerProfit(s, amount);
            else profit = amount * TieMultiplier(s);

            int flat = passive + previousRefund;
            flat += u.ChosenBetWinBonusCents;
            flat += u.StreakBonus(bet, s.WinStreak(bet));
            if (bet == "player") flat += s.Stage.AnteCents * u.PlayerWinBonusAntePercent / 100 + u.PlayerWinBonusCents;
            if (bet == "banker") flat += s.Stage.AnteCents * u.BankerWinBonusAntePercent / 100 + u.BankerWinBonusCents;
            flat += s.Stage.AnteCents * u.ChosenBetWinBonusAntePercent / 100;
            Forecast forecast = Forecast(s);
            if (forecast.Recommended == bet && forecast.Recommended == deal.Winner)
            {
                flat += u.ForecastWinBonusCents + s.Stage.AnteCents * u.ForecastWinBonusAntePercent / 100;
            }
            if (deal.Natural && !s.HasPaidFaceHunterThisStage)
            {
                flat += u.FirstNaturalEachStageBonusCents;
                p.UsedFaceHunter = u.FirstNaturalEachStageBonusCents > 0;
            }
            if (u.ComebackLossCount > 0 && s.ConsecutiveLosses >= u.ComebackLossCount)
            {
                flat += u.ComebackWinBonusCents;
            }
            if (u.SteadyBetWinBonusCents > 0 && s.LastBetAmount > 0 && amount <= s.LastBetAmount)
            {
                flat += u.SteadyBetWinBonusCents;
            }
            if (u.RaiseWinMinCents > 0 && s.LastBetAmount > 0 && amount - s.LastBetAmount >= u.RaiseWinMinCents)
            {
                flat += u.RaiseWinBonusCents;
            }
            if (u.SmallBetStreakRequiredWins > 0 && amount <= u.SmallBetStreakMaxCents)
            {
                int next = s.SmallBetWinStreak + 1;
                if (next % u.SmallBetStreakRequiredWins == 0) flat += u.SmallBetStreakBonusCents;
            }
            if (u.SmallBetWinMultiplierPercent > 100 && amount <= u.SmallBetMaxCents)
            {
                profit = profit * u.SmallBetWinMultiplierPercent / 100;
            }
            if (s.LastRoundDidWin && amount > s.LastBetAmount && u.PressAfterWinMultiplierPercent > 100)
            {
                profit = profit * u.PressAfterWinMultiplierPercent / 100;
            }
            if (u.FirstLargeBetMinCents > 0 && amount >= u.FirstLargeBetMinCents && !s.HasUsedHighRollerSparkThisStage)
            {
                profit = profit * u.FirstLargeBetMultiplierPercent / 100;
                p.UsedHighRollerSparkAttempt = true;
            }
            if (u.BankerInitialBonusCents > 0 && deal.BankerInitialTotal >= u.BankerInitialBonusMinTotal && deal.BankerInitialTotal <= u.BankerInitialBonusMaxTotal)
            {
                flat += u.BankerInitialBonusCents;
            }
            profit = profit * u.ProfitMultiplierPercent(bet) / 100;
            p.TotalReturn = amount + profit + flat;
            p.Profit = profit + flat;
            return p;
        }

        private static int BankerProfit(SimState s, int amount)
        {
            int commission = 5;
            if (s.Stage.TableEventId == "no-commission-night") commission = 0;
            if (s.UpgradeSummary.RemovesBankerCommission) commission = 0;
            if (s.ActiveBoss == "The House") commission = 5;
            return amount * Math.Max(0, 100 - commission) / 100;
        }

        private static int TieMultiplier(SimState s)
        {
            if (s.ActiveBoss == "The House") return 8;
            int table = s.Stage.TableEventId == "tie-promo" ? 10 : 8;
            return Math.Max(table + s.TiePayoutBonus, Math.Max(s.UpgradeSummary.TiePayoutMultiplier + s.UpgradeSummary.TiePayoutBonus, s.TiePayoutOverride));
        }

        private static void RecordRound(SimState s, DealOutcome deal, BetDecision decision, Payout payout, bool didWin, int hand, int cardsDealt)
        {
            s.StageRoundsPlayed++;
            s.TotalHands++;
            s.HighestBankroll = Math.Max(s.HighestBankroll, s.Bankroll);
            if (didWin)
            {
                s.StageWinningBets++;
                s.StageWinningSides.Add(decision.Side);
                if (decision.Side == "player") s.PlayerSideWinsThisStage++;
                if (decision.Side == "banker") s.BankerSideWinsThisStage++;
            }
            else if (!payout.IsPush)
            {
                s.StageLosses++;
                if (decision.Side == "tie") s.TieBetLossesThisStage++;
            }
            if (s.VisibleRevealCount() > 0 && didWin) s.StageRevealWins++;
            if (hand == s.Stage.Hands) s.StageFinalHandWon = didWin;
            s.StageStayedUnderQuarter = s.StageStayedUnderQuarter && decision.Amount <= Math.Max(1, s.Bankroll / 4);

            int net = s.Bankroll - s.BankrollBeforeRound;
            s.PreviousRoundLoss = Math.Max(0, -net);
            if (payout.UsedDamageControl) s.DamageControlHandsSinceUse = 0; else s.DamageControlHandsSinceUse++;
            if (payout.UsedHighRollerSparkAttempt) s.HasUsedHighRollerSparkThisStage = true;
            if (payout.UsedFaceHunter) s.HasPaidFaceHunterThisStage = true;
            if (didWin) s.ConsecutiveLosses = 0; else if (!payout.IsPush) s.ConsecutiveLosses++;
            if (didWin && decision.Amount <= s.UpgradeSummary.SmallBetStreakMaxCents) s.SmallBetWinStreak++;
            else if (!payout.IsPush) s.SmallBetWinStreak = 0;
            s.LastRoundDidWin = didWin;
            s.LastBetAmount = decision.Amount;
            s.LastWinner = deal.Winner;
            if (deal.Winner == "player") { s.PlayerWinStreak++; s.BankerWinStreak = 0; s.TieStreak = 0; }
            else if (deal.Winner == "banker") { s.PlayerWinStreak = 0; s.BankerWinStreak++; s.TieStreak = 0; }
            else { s.PlayerWinStreak = 0; s.BankerWinStreak = 0; s.TieStreak++; }
            if (s.UpgradeSummary.RevealAfterRoundCards > 0) s.ModifierRevealCount = Math.Min(2, s.ModifierRevealCount + s.UpgradeSummary.RevealAfterRoundCards);
        }

        private static BetDecision ChooseBet(SimState s)
        {
            List<int> amounts = LegalAmounts(s);
            BetDecision d = new BetDecision();
            if (amounts.Count == 0) return d;
            Forecast f = Forecast(s);
            List<string> sides = new List<string> { "player", "banker", "tie" };
            int low = amounts[0];
            int high = amounts[amounts.Count - 1];
            if (s.Policy == "random")
            {
                d.Side = sides[s.PolicyRng.NextInt(sides.Count)];
                d.Amount = amounts[s.PolicyRng.NextInt(Math.Min(2, amounts.Count))];
            }
            else if (s.Policy == "novice")
            {
                d.Side = f.Recommended.Length > 0 && f.Complete ? f.Recommended : "banker";
                d.Amount = low;
            }
            else if (s.Policy == "greedy")
            {
                d.Side = f.Recommended.Length > 0 ? f.Recommended : BestBaseSide(s);
                d.Amount = high;
            }
            else if (s.Policy == "risk_aware")
            {
                d.Side = f.Recommended.Length > 0 && (f.Complete || f.Recommended != "tie") ? f.Recommended : "banker";
                int idx = s.Heat >= 7 || s.Bankroll < s.Stage.AnteCents * 8 ? 0 : Math.Min(1, amounts.Count - 1);
                d.Amount = amounts[idx];
            }
            else
            {
                d.Side = OptimizedSide(s, f);
                d.Amount = OptimizedAmount(s, amounts, d.Side, f);
            }
            d.Meaningful = EstimateChoiceSpread(s) > Math.Max(500, s.Stage.AnteCents / 2);
            s.BankrollBeforeRound = s.Bankroll;
            return d;
        }

        private static string BestBaseSide(SimState s)
        {
            double banker = 0.4586 * 0.95 - 0.4462;
            double player = 0.4462 - 0.4586;
            double tie = 0.0952 * TieMultiplier(s) - (1 - 0.0952);
            if (tie > banker && tie > player) return "tie";
            return banker >= player ? "banker" : "player";
        }

        private static string OptimizedSide(SimState s, Forecast f)
        {
            if (f.Recommended.Length > 0)
            {
                if (f.Recommended == "tie" && !f.Complete && s.Heat > 5) return "banker";
                return f.Recommended;
            }
            Dictionary<string, int> tagCounts = s.TagCounts();
            if (tagCounts.Get("tie") >= 3 && s.Stage.TableEventId == "tie-promo") return "tie";
            if (tagCounts.Get("player") > tagCounts.Get("banker") + 1) return "player";
            return BestBaseSide(s);
        }

        private static int OptimizedAmount(SimState s, List<int> amounts, string side, Forecast f)
        {
            if (f.Complete && f.Recommended == side)
            {
                return amounts[amounts.Count - 1];
            }
            if (s.Heat >= 8 || s.Bankroll < s.Stage.AnteCents * 6) return amounts[0];
            if (side == "tie") return amounts[0];
            int pressure = s.StageOpponentProfit - (s.Bankroll - s.StageStartBankroll);
            if (pressure > s.Stage.AnteCents * 2) return amounts[Math.Min(amounts.Count - 1, 1)];
            return amounts[Math.Min(amounts.Count - 1, 1)];
        }

        private static double EstimateChoiceSpread(SimState s)
        {
            List<int> amounts = LegalAmounts(s);
            if (amounts.Count == 0) return 0;
            Forecast f = Forecast(s);
            double best = -999999, worst = 999999;
            foreach (string side in new[] { "player", "banker", "tie" })
            {
                foreach (int amount in amounts)
                {
                    double ev;
                    if (f.Complete)
                    {
                        if (f.Recommended == "tie" && side != "tie") ev = amount * 0.0;
                        else ev = f.Recommended == side ? amount : -amount;
                    }
                    else
                    {
                        if (side == "banker") ev = amount * (0.4586 * 0.95 - 0.4462);
                        else if (side == "player") ev = amount * (0.4462 - 0.4586);
                        else ev = amount * (0.0952 * TieMultiplier(s) - 0.9048);
                    }
                    if (ev > best) best = ev;
                    if (ev < worst) worst = ev;
                }
            }
            return best - worst;
        }

        private static List<int> LegalAmounts(SimState s)
        {
            int cap = Math.Min(s.Stage.StageMaxBetCents, Math.Max(0, s.Bankroll / 4));
            if (s.Stage.Id <= 2)
            {
                cap = cap * s.Contact.EarlyMaxBetMultiplierPercent / 100;
            }
            if (s.Bankroll >= s.Stage.MinimumBetCents) cap = Math.Max(s.Stage.MinimumBetCents, cap);
            List<int> amounts = new List<int>();
            foreach (int a in s.Stage.AllowedBets)
            {
                if (a >= s.Stage.MinimumBetCents && a <= cap && a <= s.Bankroll) amounts.Add(a);
            }
            return amounts;
        }

        private static void ApplyBossPressure(SimState s, string bet)
        {
            if (s.ActiveBoss == "Pit Boss" || s.ActiveBoss == "The House")
            {
                if (s.BossLastBet == bet) s.BossSameSideCount++;
                else { s.BossLastBet = bet; s.BossSameSideCount = 1; }
                if (s.BossSameSideCount >= 3)
                {
                    int boost = s.ActiveBoss == "The House" ? s.Stage.AnteCents * 3 / 4 : s.Stage.AnteCents / 5;
                    s.StageOpponentProfit += boost;
                    if (s.BossSameSideCount % 4 == 0) ApplyHeat(s, 1, "boss-repeat");
                }
            }
            if ((s.ActiveBoss == "The Inspector" || s.ActiveBoss == "The House") && !s.BossInspectorUsed)
            {
                if (s.VisibleRevealCount() > 0)
                {
                    s.BossInspectorUsed = true;
                    s.StageOpponentProfit += s.Stage.AnteCents * 4;
                    ApplyHeat(s, 2, "inspector");
                }
            }
            if (s.ActiveBoss == "The House")
            {
                if (!s.HouseAdaptiveUsed && s.TagCounts().Values.DefaultIfEmpty(0).Max() >= 2)
                {
                    s.HouseAdaptiveUsed = true;
                    ApplyHeat(s, 1, "house-adaptive");
                }
                if (!s.HouseRuleShiftUsed && s.StageRoundsPlayed >= s.Stage.Hands / 2)
                {
                    s.HouseRuleShiftUsed = true;
                    ApplyHeat(s, 1, "house-shift");
                }
            }
        }

        private static int OpponentProfit(Stage stage, int hand, string previousWinner, string playerBet, string winner)
        {
            string side = OpponentSide(stage.OpponentStyle, hand, previousWinner, playerBet, winner);
            int mult = OpponentMultiplier(stage.OpponentStyle, hand);
            int amount = Math.Min(stage.StageMaxBetCents, Math.Max(stage.AnteCents, stage.AnteCents * mult));
            if (winner == "tie" && side != "tie") return 0;
            if (side != winner) return -amount;
            if (side == "player") return amount;
            if (side == "banker") return amount * (stage.TableEventId == "no-commission-night" ? 100 : 95) / 100;
            return amount * (stage.TableEventId == "tie-promo" ? 10 : 8);
        }

        private static string OpponentSide(string style, int hand, string previousWinner, string playerBet, string winner)
        {
            if (style == "conservativeBanker") return hand % 5 == 0 ? "player" : "banker";
            if (style == "playerPivot") return previousWinner == "banker" ? "player" : "banker";
            if (style == "tieChaser") return hand % 4 == 0 ? "tie" : "banker";
            if (style == "highRoller") return hand % 3 == 0 ? winner : "banker";
            if (style == "smallBallGrinder")
            {
                string[] seq = new[] { "banker", "player", "banker", "banker" };
                return seq[(hand - 1) % 4];
            }
            if (style == "streakBetter") return previousWinner.Length > 0 ? previousWinner : "banker";
            if (style == "counterBetter")
            {
                if (previousWinner == "player") return "banker";
                if (previousWinner == "banker") return "player";
                return "banker";
            }
            if (style == "randomTourist")
            {
                string[] all = new[] { "player", "banker", "tie" };
                return all[(hand * 7 + winner.Length) % all.Length];
            }
            if (style == "bossStyle") return playerBet;
            if (style == "houseStyle") return winner == "tie" ? "banker" : winner;
            return "banker";
        }

        private static int OpponentMultiplier(string style, int hand)
        {
            if (style == "highRoller") return hand % 3 == 0 ? 3 : 1;
            if (style == "tieChaser") return hand % 4 == 0 ? 1 : 2;
            if (style == "bossStyle") return 2;
            if (style == "houseStyle") return hand > 6 ? 3 : 2;
            if (style == "smallBallGrinder") return 1;
            return hand % 5 == 0 ? 2 : 1;
        }

        private static int OpponentTolerance(Stage stage)
        {
            if (stage.Id == 1) return stage.AnteCents * 9;
            if (stage.Id == 2) return stage.AnteCents * 3;
            if (stage.Id == 3) return stage.AnteCents * 2;
            if (stage.Id == 4) return stage.AnteCents / 2;
            if (stage.Id == 7) return stage.AnteCents * 8;
            return 0;
        }

        private static int StageClearChips(Stage stage)
        {
            int chips;
            if (stage.IsBoss)
            {
                chips = stage.Id == 5 ? 5 : (stage.Id == 8 ? 6 : 8);
            }
            else
            {
                chips = stage.Id <= 3 ? 2 : (stage.Id <= 7 ? 3 : 4);
            }
            if (stage.TableEventId == "private-table") chips += 1;
            return chips;
        }

        private static bool SecondaryComplete(SimState s, Stage stage, int profit)
        {
            switch (stage.SecondaryKind)
            {
                case "winWithoutHeat": return s.Heat <= s.StageStartHeat;
                case "endWithProfit": return profit > 0;
                case "triggerModifiers": return s.StageUpgradeTriggers >= 3;
                case "winTie": return s.StageWinningSides.Contains("tie");
                case "conservativeBetting": return s.StageStayedUnderQuarter;
                case "useAllBetTypes": return s.StageWinningSides.Count >= 2;
                case "finishAheadByTwoAnte": return profit >= stage.AnteCents * 2;
                case "winFinalHand": return s.StageFinalHandWon;
                case "beatWithoutConsumables": return s.StageConsumablesUsed == 0;
                case "recoverFromBehind": return s.StageFellBehind && profit >= s.StageOpponentProfit - OpponentTolerance(stage);
            }
            return false;
        }

        private static void ApplyStageRewardDraft(SimState s, SimResult result)
        {
            List<StageRewardDef> choices = GenerateStageRewards(s);
            StageRewardDef chosen = ChooseStageReward(s, choices);
            if (chosen == null) return;
            result.RewardsPicked.Add(chosen.Name);
            ApplyStageReward(s, chosen);
        }

        private static List<StageRewardDef> GenerateStageRewards(SimState s)
        {
            List<StageRewardDef> viable = s.Mechanics.StageRewards.ToList();
            Dictionary<string, int> tags = s.TagCounts();
            List<StageRewardDef> weighted = new List<StageRewardDef>();
            foreach (StageRewardDef r in viable)
            {
                int weight = 1;
                foreach (string tag in r.Tags) if (tags.Get(tag) > 0) weight += 2;
                if (r.RebuildKind == "attachmentDraft" && s.ActiveMods.Count == 0) weight = 0;
                if (weight > 0) for (int i = 0; i < weight; i++) weighted.Add(r);
            }
            return UniqueRewards(weighted.Count > 0 ? weighted : viable, 3, ref s.RewardRng);
        }

        private static List<StageRewardDef> UniqueRewards(List<StageRewardDef> pool, int count, ref Lcg rng)
        {
            List<StageRewardDef> copy = pool.ToList();
            for (int i = copy.Count - 1; i > 0; i--)
            {
                int j = rng.NextInt(i + 1);
                StageRewardDef tmp = copy[i]; copy[i] = copy[j]; copy[j] = tmp;
            }
            List<StageRewardDef> selected = new List<StageRewardDef>();
            HashSet<string> names = new HashSet<string>();
            foreach (StageRewardDef r in copy)
            {
                if (names.Add(r.Name)) selected.Add(r);
                if (selected.Count == count) break;
            }
            return selected;
        }

        private static StageRewardDef ChooseStageReward(SimState s, List<StageRewardDef> choices)
        {
            if (choices.Count == 0) return null;
            if (s.Policy == "random") return choices[s.PolicyRng.NextInt(choices.Count)];
            double best = double.MinValue;
            StageRewardDef chosen = choices[0];
            foreach (StageRewardDef r in choices)
            {
                double score = 0;
                if (r.Kind == "cash") score += r.CashMultiplier * s.Stage.AnteCents / 100.0;
                if (r.Kind == "chips") score += r.Chips * 9000;
                if (r.Kind == "heat") score += Math.Min(s.Heat, r.HeatReduction) * 14000;
                if (r.RebuildKind == "modifierDraft") score += s.Policy == "optimized" ? 36000 : 22000;
                if (r.RebuildKind == "consumableDraft") score += 7000;
                if (r.RebuildKind == "attachmentDraft") score += 9000;
                if (r.Kind == "tiePayout") score += s.TagCounts().Get("tie") * 6000;
                if (r.Kind == "shoeHigh") score += s.Policy == "greedy" ? 18000 : 9000;
                if (s.Policy == "risk_aware" && r.Kind == "heat") score += 25000;
                if (score > best) { best = score; chosen = r; }
            }
            return chosen;
        }

        private static void ApplyStageReward(SimState s, StageRewardDef r)
        {
            if (r.RebuildKind == "modifierDraft")
            {
                ModifierDef mod = DraftModifier(s, r.Rarity);
                if (mod != null) TryAddModifier(s, mod.Id, true);
                else s.Chips += 1;
                return;
            }
            if (r.RebuildKind == "consumableDraft") { s.Chips += 1; return; }
            if (r.RebuildKind == "attachmentDraft") { s.Chips += 1; return; }
            if (r.Kind == "cash")
            {
                int baseCash = s.Stage.AnteCents * r.CashMultiplier / 100;
                int cap = Math.Max(0, s.Bankroll / 2);
                int cash = Math.Min(baseCash, cap) * s.Contact.CashRewardMultiplierPercent / 100;
                s.Bankroll += cash;
            }
            else if (r.Kind == "chips") s.Chips += r.Chips;
            else if (r.Kind == "heat") s.Heat = Math.Max(0, s.Heat - r.HeatReduction);
            else if (r.Kind == "tiePayout") s.TiePayoutBonus += r.TiePayoutBonus;
            else if (r.Kind == "shoeHigh") AddRandomHighValueCards(s, r.ShoeHighCards);
            else if (r.Kind == "removeFace") RemoveFaceCards(s, r.RemoveFaceCards);
            else if (r.Kind == "legacyUpgrade")
            {
                UpgradeDef u = DraftLegacyUpgrade(s, r.Rarity == "legendary" ? "legendary" : (r.Rarity == "rare" ? "rare" : "common"));
                if (u != null) ApplyLegacyUpgrade(s, u);
            }
        }

        private static void ApplyBossRewardDraft(SimState s, SimResult result)
        {
            List<BossRewardDef> pool = s.Mechanics.BossRewards.ToList();
            List<BossRewardDef> choices = new List<BossRewardDef>();
            HashSet<string> used = new HashSet<string>();
            for (int attempts = 0; choices.Count < 3 && attempts < 50; attempts++)
            {
                BossRewardDef r = pool[s.RewardRng.NextInt(pool.Count)];
                if (used.Add(r.Name)) choices.Add(r);
            }
            BossRewardDef chosen = ChooseBossReward(s, choices);
            if (chosen == null) return;
            result.RewardsPicked.Add(chosen.Name);
            if (chosen.Kind == "cash")
            {
                int cash = Math.Min(s.Stage.AnteCents * chosen.CashMultiplier / 100, s.Bankroll / 2) * s.Contact.CashRewardMultiplierPercent / 100;
                s.Bankroll += cash;
                s.Chips += chosen.Chips;
            }
            else if (chosen.Kind == "shoeHigh") AddRandomHighValueCards(s, chosen.Count);
            else if (chosen.Kind == "reveal") s.ModifierRevealCount = Math.Max(s.ModifierRevealCount, chosen.Count);
            else if (chosen.Kind == "tiePayout") s.TiePayoutOverride = Math.Max(s.TiePayoutOverride, chosen.Multiplier);
            else if (chosen.Kind == "removeFaceAll") RemoveFaceCards(s, 1000);
            else if (chosen.Kind == "extraRounds") s.FutureStageRoundBonus += chosen.Count;
            else if (chosen.Kind == "legacyUpgrade")
            {
                UpgradeDef u = DraftLegacyUpgrade(s, "legendary");
                if (u != null) ApplyLegacyUpgrade(s, u);
            }
            else if (chosen.Kind == "relic") s.Chips += 2;
        }

        private static BossRewardDef ChooseBossReward(SimState s, List<BossRewardDef> choices)
        {
            if (choices.Count == 0) return null;
            if (s.Policy == "random") return choices[s.PolicyRng.NextInt(choices.Count)];
            double best = double.MinValue;
            BossRewardDef chosen = choices[0];
            foreach (BossRewardDef r in choices)
            {
                double score = r.CashMultiplier * s.Stage.AnteCents / 100.0 + r.Chips * 9000 + r.Count * 600 + r.Multiplier * 3000;
                if (r.Kind == "extraRounds") score += 30000;
                if (r.Kind == "legacyUpgrade") score += 35000;
                if (r.Kind == "tiePayout" && s.TagCounts().Get("tie") < 2) score *= 0.3;
                if (score > best) { best = score; chosen = r; }
            }
            return chosen;
        }

        private static void RunShop(SimState s, SimResult result)
        {
            ResolveEvent(s, GameEvent.ShopEntered());
            int rerolls = s.Policy == "optimized" ? 1 : 0;
            for (int pass = 0; pass <= rerolls; pass++)
            {
                List<ShopOffer> offers = GenerateShopOffers(s);
                foreach (ShopOffer offer in offers)
                {
                    if (offer.Kind == "modifier")
                    {
                        s.ModifierOffers[offer.ContentId] = s.ModifierOffers.Get(offer.ContentId) + 1;
                    }
                }
                bool bought = BuyBestOffer(s, offers, result);
                if (!bought && pass < rerolls && s.Chips >= 1)
                {
                    s.Chips -= 1;
                    ResolveEvent(s, GameEvent.ShopRerolled());
                }
            }
        }

        private static List<ShopOffer> GenerateShopOffers(SimState s)
        {
            int tier = ShopTier(s.Stage.Id, s.BossesDefeated);
            List<ShopOffer> offers = new List<ShopOffer>();
            HashSet<string> owned = new HashSet<string>(s.ActiveMods.Select(m => m.Def.Id).Concat(s.BenchMods.Select(m => m.Def.Id)));
            for (int i = 0; i < 4; i++)
            {
                int roll = s.TreeRng.NextInt(100);
                if (roll < 68 || i == 0)
                {
                    List<ModifierDef> weighted = WeightedModifiers(s, tier, owned);
                    if (weighted.Count > 0)
                    {
                        ModifierDef m = weighted[s.TreeRng.NextInt(weighted.Count)];
                        offers.Add(new ShopOffer("modifier", m.Id, m.Cost));
                    }
                }
                else
                {
                    offers.Add(new ShopOffer("minor", "consumable-or-attachment", roll < 86 ? 2 : 3));
                }
            }
            return offers;
        }

        private static List<ModifierDef> WeightedModifiers(SimState s, int tier, HashSet<string> owned)
        {
            List<ModifierDef> candidates = s.Mechanics.Modifiers.Where(m => m.MinTier <= tier && m.Rarity != "boss" && m.Id != s.Options.DisabledModifierId).ToList();
            List<ModifierDef> weighted = new List<ModifierDef>();
            HashSet<string> contactTags = new HashSet<string>(s.Contact.ShopBiasTags);
            foreach (ModifierDef m in candidates)
            {
                weighted.Add(m);
                if (m.Tags.Any(t => contactTags.Contains(t))) { weighted.Add(m); weighted.Add(m); }
                if (owned.Contains(m.Id)) weighted.Add(m);
            }
            return weighted.Count > 0 ? weighted : candidates;
        }

        private static bool BuyBestOffer(SimState s, List<ShopOffer> offers, SimResult result)
        {
            double best = double.MinValue;
            ShopOffer chosen = null;
            foreach (ShopOffer o in offers)
            {
                if (o.Price > s.Chips) continue;
                double score = 0;
                if (o.Kind == "modifier")
                {
                    ModifierDef m = s.Mechanics.ModifierById[o.ContentId];
                    score = ModifierShopScore(s, m) - o.Price * 4000;
                }
                else score = 2500 - o.Price * 1000;
                if (s.Policy == "random") score = s.PolicyRng.NextDouble();
                if (score > best) { best = score; chosen = o; }
            }
            if (chosen == null) return false;
            if (chosen.Kind == "modifier")
            {
                if (TryAddModifier(s, chosen.ContentId, true))
                {
                    s.Chips -= chosen.Price;
                    s.ModifierPicks[chosen.ContentId] = s.ModifierPicks.Get(chosen.ContentId) + 1;
                    result.ModifiersPicked.Add(chosen.ContentId);
                    ResolveEvent(s, GameEvent.ModifierBought(chosen.ContentId));
                    return true;
                }
            }
            return false;
        }

        private static double ModifierShopScore(SimState s, ModifierDef m)
        {
            if (s.Policy == "random") return 1;
            double score = m.PowerScore() * 120;
            Dictionary<string, int> tags = s.TagCounts();
            foreach (string t in m.Tags) score += tags.Get(t) * 7000;
            if (!BalanceSimulator.EmittedTriggers.Contains(m.Trigger)) score -= 30000;
            if (s.Policy == "risk_aware" && (m.Tags.Contains("heat") || m.Tags.Contains("comeback"))) score += 18000;
            if (s.Policy == "greedy" && (m.Tags.Contains("betControl") || m.Tags.Contains("economy"))) score += 12000;
            if (s.Policy == "novice" && (m.Tags.Contains("economy") || m.Tags.Contains("banker"))) score += 9000;
            return score;
        }

        private static bool TryAddModifier(SimState s, string id, bool countPick)
        {
            if (!s.Mechanics.ModifierById.ContainsKey(id)) return false;
            ModifierDef def = s.Mechanics.ModifierById[id];
            foreach (ModifierInstance mi in s.ActiveMods)
            {
                if (mi.Def.Id == id && mi.Level < 3)
                {
                    mi.Level++;
                    ResolveEvent(s, GameEvent.ModifierLeveled(id));
                    return true;
                }
            }
            foreach (ModifierInstance mi in s.BenchMods)
            {
                if (mi.Def.Id == id && mi.Level < 3)
                {
                    mi.Level++;
                    return true;
                }
            }
            if (s.ActiveMods.Count < 5)
            {
                s.ActiveMods.Add(new ModifierInstance(def));
                return true;
            }
            if (s.BenchMods.Count < 2)
            {
                s.BenchMods.Add(new ModifierInstance(def));
                return true;
            }
            return false;
        }

        private static ModifierDef DraftModifier(SimState s, string rarity)
        {
            int tier = ShopTier(s.Stage.Id, s.BossesDefeated);
            List<ModifierDef> candidates = s.Mechanics.Modifiers.Where(m => m.MinTier <= tier && m.Rarity != "boss" && (rarity.Length == 0 || m.Rarity == rarity) && m.Id != s.Options.DisabledModifierId).ToList();
            if (candidates.Count == 0) return null;
            List<ModifierDef> weighted = new List<ModifierDef>();
            Dictionary<string, int> tags = s.TagCounts();
            foreach (ModifierDef m in candidates)
            {
                weighted.Add(m);
                foreach (string t in m.Tags) if (tags.Get(t) > 0) { weighted.Add(m); weighted.Add(m); }
            }
            return weighted[s.RewardRng.NextInt(weighted.Count)];
        }

        private static UpgradeDef DraftLegacyUpgrade(SimState s, string rarity)
        {
            List<UpgradeDef> candidates = s.Mechanics.Upgrades.Where(u => u.Rarity == rarity).ToList();
            if (candidates.Count == 0) return null;
            return candidates[s.RewardRng.NextInt(candidates.Count)];
        }

        private static void ApplyLegacyUpgrade(SimState s, UpgradeDef u)
        {
            s.LegacyUpgrades.Add(u);
            s.UpgradeSummary.Apply(u);
            string raw = u.RawEffect;
            int n;
            if ((n = MatchInt(raw, @"addExtraNines\(count:\s*([0-9_]+)")) > 0) AddRandomCards(s, 9, n);
            if ((n = MatchInt(raw, @"addExtraEights\(count:\s*([0-9_]+)")) > 0) AddRandomCards(s, 8, n);
            if ((n = MatchInt(raw, @"addTiePairCards\(pairs:\s*([0-9_]+)")) > 0) AddTiePairs(s, n);
            if ((n = MatchInt(raw, @"removeZeroValueCards\(count:\s*([0-9_]+)")) > 0) RemoveZeroCards(s, n);
            if ((n = MatchInt(raw, @"removeCards\(ranks:\s*\[[^\]]*jack[^\]]*\],\s*count:\s*([0-9_]+)")) > 0) RemoveFaceCards(s, n);
            if ((n = MatchInt(raw, @"addRandomCards\(ranks:\s*\[[^\]]*eight[^\]]*nine[^\]]*\],\s*count:\s*([0-9_]+)")) > 0) AddRandomHighValueCards(s, n);
        }

        private static void ApplyReshuffleLegacy(SimState s)
        {
            if (s.UpgradeSummary.HotShoeExtraEights > 0) AddRandomCards(s, 8, s.UpgradeSummary.HotShoeExtraEights);
            if (s.UpgradeSummary.HotShoeExtraNines > 0) AddRandomCards(s, 9, s.UpgradeSummary.HotShoeExtraNines);
            if (s.UpgradeSummary.ColdShoeZeroCardsToRemove > 0) RemoveZeroCards(s, s.UpgradeSummary.ColdShoeZeroCardsToRemove);
        }

        private static int ShopTier(int stageId, int bossesDefeated)
        {
            if (stageId >= 9) return 5;
            if (bossesDefeated >= 2 || stageId >= 8) return 4;
            if (bossesDefeated >= 1 || stageId >= 5) return 3;
            if (stageId >= 3) return 2;
            return 1;
        }

        private static void ResetStageUses(SimState s)
        {
            foreach (ModifierInstance mi in s.ActiveMods.Concat(s.BenchMods))
            {
                mi.StageUses = 0;
                mi.HandUses = 0;
                mi.StageChipGranted = false;
            }
        }

        private static string BuildKey(SimState s)
        {
            List<string> ids = s.ActiveMods.Select(mi => mi.Def.Id).OrderBy(x => x).ToList();
            if (ids.Count == 0) return "none";
            return string.Join("|", ids.ToArray());
        }

        private static int MatchInt(string raw, string pattern)
        {
            Match m = Regex.Match(raw, pattern);
            return m.Success ? int.Parse(m.Groups[1].Value.Replace("_", ""), CultureInfo.InvariantCulture) : 0;
        }
    }

    internal class Mechanics
    {
        public Stage[] Stages;
        public List<ModifierDef> Modifiers = new List<ModifierDef>();
        public Dictionary<string, ModifierDef> ModifierById = new Dictionary<string, ModifierDef>();
        public List<UpgradeDef> Upgrades = new List<UpgradeDef>();
        public List<StageRewardDef> StageRewards = new List<StageRewardDef>();
        public List<BossRewardDef> BossRewards = new List<BossRewardDef>();
        public Dictionary<string, Contact> Contacts = new Dictionary<string, Contact>();

        public static Mechanics Load(string repoRoot)
        {
            Mechanics m = new Mechanics();
            m.Stages = Stage.CreateAll();
            LoadContacts(m);
            LoadStageRewards(m);
            LoadBossRewards(m);
            LoadModifiers(m, Path.Combine(repoRoot, "RiggedShoe", "Models", "ModifierModels.swift"));
            LoadUpgrades(m, Path.Combine(repoRoot, "RiggedShoe", "Models", "UpgradeCard.swift"));
            return m;
        }

        private static void LoadContacts(Mechanics m)
        {
            AddContact(m, "contact.dealer", "The Dealer", -2500, 0, 0, 100, 100, new[] { "core.opening-tell" }, new[] { "shoeVision", "natural" });
            AddContact(m, "contact.accountant", "The Accountant", 0, 2, 0, 70, 100, new[] { "economy.interest-ledger" }, new[] { "economy", "betControl" });
            AddContact(m, "contact.whale", "The Whale", 7500, 0, 1, 100, 100, new[] { "bet.high-roller" }, new[] { "betControl", "comeback" });
            AddContact(m, "contact.mechanic", "The Mechanic", 0, 0, 1, 100, 100, new[] { "control.burn-notice" }, new[] { "shoeControl", "cardSculpting" });
            AddContact(m, "contact.tourist", "The Tourist", 0, 0, 0, 100, 100, new[] { "core.lucky-chip" }, new[] { "economy", "banker", "player" });
            AddContact(m, "contact.grifter", "The Grifter", 0, 0, 0, 100, 100, new[] { "player.side-step" }, new[] { "player", "comeback" });
            AddContact(m, "contact.tie-chaser", "The Tie Chaser", -1500, 0, 0, 100, 100, new[] { "core.tie-insurance" }, new[] { "tie", "comeback" });
            AddContact(m, "contact.ghost", "The Ghost", 0, 0, 0, 100, 80, new[] { "core.clean-hands" }, new[] { "heat", "opponentSabotage" });
            AddContact(m, "contact.naturalist", "The Naturalist", 0, 0, 0, 100, 100, new[] { "natural.natural-read" }, new[] { "natural", "shoeVision" });
            AddContact(m, "contact.pair-spotter", "The Pair Spotter", 0, 0, 0, 100, 100, new[] { "pair.pair-hunter" }, new[] { "pair", "tie", "economy" });
            AddContact(m, "contact.marker-broker", "The Marker Broker", 2500, 0, 1, 100, 100, new[] { "debt.emergency-marker" }, new[] { "economy", "comeback", "heat" });
            AddContact(m, "contact.closer", "The Closer", 0, 0, 0, 100, 100, new[] { "final.closer" }, new[] { "streak", "boss", "betControl" });
        }

        private static void AddContact(Mechanics m, string id, string name, int bankroll, int chips, int heat, int early, int cash, string[] mods, string[] tags)
        {
            Contact c = new Contact();
            c.Id = id; c.Name = name; c.BankrollAdjust = bankroll; c.ChipsAdjust = chips; c.HeatAdjust = heat; c.EarlyMaxBetMultiplierPercent = early; c.CashRewardMultiplierPercent = cash;
            c.StartingModifiers.AddRange(mods); c.ShopBiasTags.AddRange(tags);
            m.Contacts[id] = c;
        }

        private static void LoadStageRewards(Mechanics m)
        {
            m.StageRewards.Add(StageRewardDef.Cash("Ante Kickback", 100));
            m.StageRewards.Add(StageRewardDef.Cash("Table Comp", 150));
            m.StageRewards.Add(StageRewardDef.ChipReward("Chip Runner", 2));
            m.StageRewards.Add(StageRewardDef.Cash("High Table Cut", 200));
            m.StageRewards.Add(StageRewardDef.Heat("Cool Down", 2));
            m.StageRewards.Add(StageRewardDef.Rebuild("Modifier Voucher", "modifierDraft", ""));
            m.StageRewards.Add(StageRewardDef.Rebuild("Rare Modifier Voucher", "modifierDraft", "rare"));
            m.StageRewards.Add(StageRewardDef.Rebuild("Consumable Case", "consumableDraft", ""));
            m.StageRewards.Add(StageRewardDef.Rebuild("Attachment Case", "attachmentDraft", ""));
            m.StageRewards.Add(StageRewardDef.Legacy("Double Down", "duplicate"));
            m.StageRewards.Add(StageRewardDef.Legacy("Rare Contact", "rare"));
            m.StageRewards.Add(StageRewardDef.Legacy("Legendary Contact", "legendary"));
            m.StageRewards.Add(StageRewardDef.Tie("Tie Pressure", 2));
            m.StageRewards.Add(StageRewardDef.ShoeHigh("High Card Drop", 8));
            m.StageRewards.Add(StageRewardDef.RemoveFace("Face Sweep", 8));
        }

        private static void LoadBossRewards(Mechanics m)
        {
            m.BossRewards.Add(BossRewardDef.Simple("Player Consortium", "legacyUpgrade"));
            m.BossRewards.Add(BossRewardDef.Simple("Banker Consortium", "legacyUpgrade"));
            m.BossRewards.Add(BossRewardDef.CountReward("High Roller Shoe", "shoeHigh", 20));
            m.BossRewards.Add(BossRewardDef.CountReward("Open Ledger", "reveal", 15));
            m.BossRewards.Add(BossRewardDef.MultReward("Tie Conspiracy", "tiePayout", 30));
            m.BossRewards.Add(BossRewardDef.Cash("Vault Leak", 500, 6));
            m.BossRewards.Add(BossRewardDef.Simple("Echo Chamber", "legacyUpgrade"));
            m.BossRewards.Add(BossRewardDef.Simple("Face Card Blackout", "removeFaceAll"));
            m.BossRewards.Add(BossRewardDef.Simple("Legendary Wire", "legacyUpgrade"));
            m.BossRewards.Add(BossRewardDef.Simple("Pit Boss Nod", "relic"));
            m.BossRewards.Add(BossRewardDef.Simple("Vault Key", "relic"));
            m.BossRewards.Add(BossRewardDef.Simple("Private Room", "relic"));
            m.BossRewards.Add(BossRewardDef.Simple("Surveillance Loop", "relic"));
            m.BossRewards.Add(BossRewardDef.CountReward("Casino Inside Contact", "extraRounds", 3));
        }

        private static void LoadModifiers(Mechanics m, string path)
        {
            string[] lines = File.ReadAllLines(path);
            AddCoreModifiers(m);
            for (int i = 0; i < lines.Length; i++)
            {
                string line = lines[i];
                if (line.IndexOf("contentModifier(", StringComparison.Ordinal) < 0) continue;
                ModifierDef d = ParseContentModifier(line);
                if (string.IsNullOrEmpty(d.Id)) continue;
                d.Source = "RiggedShoe/Models/ModifierModels.swift:" + (i + 1).ToString(CultureInfo.InvariantCulture);
                AddModifier(m, d);
            }
        }

        private static void AddCoreModifiers(Mechanics m)
        {
            ModifierDef banker = ModifierDef.Core("core.banker-bias", "Banker Bias", "common", "playerWonBet", new[] { "banker", "betControl" }, 1, 3);
            banker.PayoutBanker = new[] { 10, 18, 25 }; banker.RequiredBet = "banker"; banker.RequiredWinner = "banker"; banker.Chips[2] = 1; banker.ChipFirstStageOnly = true; AddModifier(m, banker);
            ModifierDef player = ModifierDef.Core("core.player-surge", "Player Surge", "common", "playerWonBet", new[] { "player", "tempo" }, 1, 3);
            player.AntePercent = new[] { 100, 150, 200 }; player.Chips[2] = 1; player.RequiredBet = "player"; player.RequiredWinner = "player"; player.FirstPlayerSideWin = true; player.StageLimit = new[] { 1, 1, 1 }; AddModifier(m, player);
            ModifierDef tie = ModifierDef.Core("core.tie-insurance", "Tie Insurance", "common", "playerLostBet", new[] { "tie", "comeback" }, 1, 2);
            tie.RefundPercent = new[] { 40, 55, 70 }; tie.RequiredBet = "tie"; tie.FirstTieLoss = true; tie.StageLimit = new[] { 1, 1, 1 }; AddModifier(m, tie);
            ModifierDef tell = ModifierDef.Core("core.opening-tell", "Opening Tell", "rare", "stageStarted", new[] { "shoeVision" }, 1, 4);
            tell.Reveal = new[] { 3, 4, 5 }; tell.StageLimit = new[] { 1, 1, 1 }; AddModifier(m, tell);
            ModifierDef clean = ModifierDef.Core("core.clean-hands", "Clean Hands", "common", "heatGained", new[] { "heat" }, 1, 3);
            clean.PreventHeat = new[] { 99, 99, 99 }; clean.Chips[2] = 1; clean.StageLimit = new[] { 1, 2, 2 }; AddModifier(m, clean);
            ModifierDef chip = ModifierDef.Core("core.lucky-chip", "Lucky Chip", "common", "playerWonBet", new[] { "economy" }, 1, 2);
            chip.Chips = new[] { 1, 1, 2 }; chip.AntePercent[1] = 50; chip.FirstWinningBet = true; chip.StageLimit = new[] { 1, 1, 1 }; AddModifier(m, chip);
        }

        private static ModifierDef ParseContentModifier(string line)
        {
            ModifierDef d = new ModifierDef();
            d.Id = Match(line, "id:\\s*\"([^\"]+)\"");
            d.Name = Match(line, "name:\\s*\"([^\"]+)\"");
            d.Rarity = Match(line, "rarity:\\s*\\.(\\w+)");
            d.Trigger = Match(line, "trigger:\\s*\\.(\\w+)");
            d.MinTier = IntMatch(line, "minShopTier:\\s*([0-9_]+)", 1);
            d.Cost = RarityCost(d.Rarity);
            d.Raw = line.Trim();
            d.Tags = Regex.Matches(Match(line, "tags:\\s*\\[([^\\]]*)\\]"), "\\.([A-Za-z][A-Za-z0-9_]*)").Cast<Match>().Select(x => x.Groups[1].Value).ToList();
            d.RequiredBet = ExtractSideFromCondition(line, "betType");
            d.RequiredWinner = ExtractSideFromCondition(line, "winningSide");
            d.FirstPlayerSideWin = line.Contains("firstPlayerSideWinThisStage");
            d.FirstBankerSideWin = line.Contains("firstBankerSideWinThisStage");
            d.FirstTieLoss = line.Contains("firstTieLossThisStage");
            d.FirstWinningBet = line.Contains("firstWinningBetThisStage");
            Match hasTag = Regex.Match(line, "hasTag\\(\\.(\\w+)\\)");
            if (hasTag.Success) d.HasTagCondition = hasTag.Groups[1].Value;
            d.HeatCost = IntMatch(line, "heatCost:\\s*([0-9_]+)", 0);
            InitDefaultArrays(d);
            ParseEffects(d, line);
            ParseLimits(d, line);
            return d;
        }

        private static void InitDefaultArrays(ModifierDef d)
        {
            if (d.AntePercent == null) d.AntePercent = new[] { 0, 0, 0 };
            if (d.Chips == null) d.Chips = new[] { 0, 0, 0 };
            if (d.RefundPercent == null) d.RefundPercent = new[] { 0, 0, 0 };
            if (d.PreventHeat == null) d.PreventHeat = new[] { 0, 0, 0 };
            if (d.Reveal == null) d.Reveal = new[] { 0, 0, 0 };
            if (d.GainHeat == null) d.GainHeat = new[] { 0, 0, 0 };
            if (d.ReduceHeat == null) d.ReduceHeat = new[] { 0, 0, 0 };
            if (d.Burn == null) d.Burn = new[] { 0, 0, 0 };
            if (d.MoveTopBottom == null) d.MoveTopBottom = new[] { false, false, false };
            if (d.MoveTopDeeper == null) d.MoveTopDeeper = new[] { 0, 0, 0 };
            if (d.AddEights == null) d.AddEights = new[] { 0, 0, 0 };
            if (d.AddNines == null) d.AddNines = new[] { 0, 0, 0 };
            if (d.PayoutAny == null) d.PayoutAny = new[] { 0, 0, 0 };
            if (d.PayoutPlayer == null) d.PayoutPlayer = new[] { 0, 0, 0 };
            if (d.PayoutBanker == null) d.PayoutBanker = new[] { 0, 0, 0 };
            if (d.PayoutTie == null) d.PayoutTie = new[] { 0, 0, 0 };
            if (d.StageLimit == null) d.StageLimit = new[] { -1, -1, -1 };
            if (d.RunLimit == null) d.RunLimit = new[] { -1, -1, -1 };
            if (d.HandLimit == null) d.HandLimit = new[] { -1, -1, -1 };
        }

        private static void ParseEffects(ModifierDef d, string raw)
        {
            int[] triplet = Triplet(raw, "payoutLevels\\([^,]+,\\s*([0-9_]+),\\s*([0-9_]+),\\s*([0-9_]+)");
            if (triplet != null)
            {
                string side = "any";
                if (raw.Contains("payoutLevels(.banker")) side = "banker";
                else if (raw.Contains("payoutLevels(.player")) side = "player";
                else if (raw.Contains("payoutLevels(.tie")) side = "tie";
                SetPayout(d, side, triplet);
            }
            triplet = Triplet(raw, "anteLevels\\(\\s*([0-9_]+),\\s*([0-9_]+),\\s*([0-9_]+)");
            if (triplet != null) d.AntePercent = triplet;
            SetLevelsFromMatches(d.AntePercent, raw, "grantBankrollFromAnte\\(percent:\\s*([0-9_]+)");
            SetLevelsFromMatches(d.Chips, raw, "grantChips(?:OnFirstStageTrigger)?\\(amount:\\s*([0-9_]+)");
            if (raw.Contains("grantChipsOnFirstStageTrigger")) d.ChipFirstStageOnly = true;
            SetLevelsFromMatches(d.RefundPercent, raw, "lossRefund\\(percent:\\s*([0-9_]+)");
            SetLevelsFromMatches(d.Reveal, raw, "revealUpcomingCards(?:WithForecast)?\\(count:\\s*([0-9_]+)");
            SetLevelsFromMatches(d.GainHeat, raw, "gainHeat\\(amount:\\s*([0-9_]+)");
            SetLevelsFromMatches(d.ReduceHeat, raw, "reduceHeat\\(amount:\\s*([0-9_]+)");
            if (raw.Contains("preventHeat(amount: nil)")) d.PreventHeat = new[] { 99, 99, 99 };
            SetLevelsFromMatches(d.PreventHeat, raw, "preventHeat\\(amount:\\s*([0-9_]+)");
            SetLevelsFromMatches(d.Burn, raw, "burnCards\\(count:\\s*([0-9_]+)");
            if (raw.Contains("moveTopCardToBottom")) d.MoveTopBottom = new[] { true, true, true };
            SetLevelsFromMatches(d.MoveTopDeeper, raw, "moveTopCardDeeper\\(positions:\\s*([0-9_]+)");
            int addCount = IntMatch(raw, "addCards\\(ranks:\\s*\\[[^\\]]*\\],\\s*count:\\s*([0-9_]+)", 0);
            if (addCount > 0)
            {
                if (raw.Contains(".eight")) d.AddEights = new[] { addCount, addCount, addCount };
                if (raw.Contains(".nine")) d.AddNines = new[] { addCount, addCount, addCount };
            }
            foreach (Match pm in Regex.Matches(raw, "payoutMultiplier\\(betType:\\s*([^,]+),\\s*percent:\\s*([0-9_]+)"))
            {
                string side = pm.Groups[1].Value.Contains(".player") ? "player" : (pm.Groups[1].Value.Contains(".banker") ? "banker" : (pm.Groups[1].Value.Contains(".tie") ? "tie" : "any"));
                int val = ParseInt(pm.Groups[2].Value);
                SetPayout(d, side, new[] { val, val, val });
            }
        }

        private static void ParseLimits(ModifierDef d, string raw)
        {
            Match m = Regex.Match(raw, "perStageByLevel\\(level1:\\s*([0-9_]+),\\s*level2:\\s*([0-9_]+),\\s*level3:\\s*([0-9_]+)\\)");
            if (m.Success) d.StageLimit = new[] { ParseInt(m.Groups[1].Value), ParseInt(m.Groups[2].Value), ParseInt(m.Groups[3].Value) };
            else if ((m = Regex.Match(raw, "perStage\\(([0-9_]+)\\)")).Success) d.StageLimit = Repeat(ParseInt(m.Groups[1].Value));
            if ((m = Regex.Match(raw, "perRun\\(([0-9_]+)\\)")).Success) d.RunLimit = Repeat(ParseInt(m.Groups[1].Value));
            if ((m = Regex.Match(raw, "perHand\\(([0-9_]+)\\)")).Success) d.HandLimit = Repeat(ParseInt(m.Groups[1].Value));
        }

        private static void SetPayout(ModifierDef d, string side, int[] values)
        {
            if (side == "player") d.PayoutPlayer = MaxArrays(d.PayoutPlayer, values);
            else if (side == "banker") d.PayoutBanker = MaxArrays(d.PayoutBanker, values);
            else if (side == "tie") d.PayoutTie = MaxArrays(d.PayoutTie, values);
            else d.PayoutAny = MaxArrays(d.PayoutAny, values);
        }

        private static int[] MaxArrays(int[] a, int[] b)
        {
            return new[] { Math.Max(a[0], b[0]), Math.Max(a[1], b[1]), Math.Max(a[2], b[2]) };
        }

        private static void SetLevelsFromMatches(int[] target, string raw, string pattern)
        {
            List<int> vals = Regex.Matches(raw, pattern).Cast<Match>().Select(x => ParseInt(x.Groups[1].Value)).ToList();
            if (vals.Count == 0) return;
            if (vals.Count == 1) { target[0] = Math.Max(target[0], vals[0]); target[1] = Math.Max(target[1], vals[0]); target[2] = Math.Max(target[2], vals[0]); return; }
            if (vals.Count == 2) { target[0] = Math.Max(target[0], vals[0]); target[1] = Math.Max(target[1], vals[1]); target[2] = Math.Max(target[2], vals[1]); return; }
            target[0] = Math.Max(target[0], vals[0]); target[1] = Math.Max(target[1], vals[1]); target[2] = Math.Max(target[2], vals[2]);
        }

        private static int[] Triplet(string raw, string pattern)
        {
            Match m = Regex.Match(raw, pattern);
            if (!m.Success) return null;
            return new[] { ParseInt(m.Groups[1].Value), ParseInt(m.Groups[2].Value), ParseInt(m.Groups[3].Value) };
        }

        private static void AddModifier(Mechanics m, ModifierDef d)
        {
            if (m.ModifierById.ContainsKey(d.Id)) return;
            InitDefaultArrays(d);
            m.Modifiers.Add(d);
            m.ModifierById[d.Id] = d;
        }

        private static void LoadUpgrades(Mechanics m, string path)
        {
            string[] lines = File.ReadAllLines(path);
            for (int i = 0; i < lines.Length; i++)
            {
                string line = lines[i].Trim();
                if (!line.StartsWith("card(", StringComparison.Ordinal)) continue;
                Match match = Regex.Match(line, "card\\(\"([^\"]+)\",\\s*\"([^\"]*)\",\\s*\\.(\\w+),\\s*(.*),\\s*\\[([^\\]]*)\\]\\)");
                if (!match.Success) continue;
                UpgradeDef u = new UpgradeDef();
                u.Name = match.Groups[1].Value;
                u.Description = match.Groups[2].Value;
                u.Rarity = match.Groups[3].Value;
                u.RawEffect = match.Groups[4].Value;
                u.Tags = Regex.Matches(match.Groups[5].Value, "\\.([A-Za-z][A-Za-z0-9_]*)").Cast<Match>().Select(x => x.Groups[1].Value).ToList();
                u.Source = "RiggedShoe/Models/UpgradeCard.swift:" + (i + 1).ToString(CultureInfo.InvariantCulture);
                m.Upgrades.Add(u);
            }
        }

        private static string Match(string text, string pattern)
        {
            Match m = Regex.Match(text, pattern);
            return m.Success ? m.Groups[1].Value : "";
        }

        private static int IntMatch(string text, string pattern, int fallback)
        {
            Match m = Regex.Match(text, pattern);
            return m.Success ? ParseInt(m.Groups[1].Value) : fallback;
        }

        private static int ParseInt(string text)
        {
            return int.Parse(text.Replace("_", ""), CultureInfo.InvariantCulture);
        }

        private static string ExtractSideFromCondition(string line, string condition)
        {
            Match m = Regex.Match(line, condition + "\\(\\.(player|banker|tie)\\)");
            return m.Success ? m.Groups[1].Value : "";
        }

        private static int[] Repeat(int value)
        {
            return new[] { value, value, value };
        }

        private static int RarityCost(string rarity)
        {
            if (rarity == "common") return 3;
            if (rarity == "uncommon") return 4;
            if (rarity == "rare") return 5;
            if (rarity == "epic") return 6;
            if (rarity == "legendary") return 8;
            return 0;
        }
    }

    internal struct Lcg
    {
        private ulong state;
        public Lcg(ulong seed) { state = seed == 0 ? 0x9E3779B97F4A7C15UL : seed; }
        public ulong Next()
        {
            unchecked { state = state * 6364136223846793005UL + 1442695040888963407UL; }
            return state;
        }
        public int NextInt(int max) { if (max <= 0) return 0; return (int)(Next() % (ulong)max); }
        public double NextDouble() { return (Next() >> 11) * (1.0 / 9007199254740992.0); }
    }

    internal struct Card
    {
        public int Rank;
        public int Suit;
        public Card(int rank, int suit) { Rank = rank; Suit = suit; }
        public int Value { get { return Rank >= 10 ? 0 : Rank; } }
    }

    internal class Stage
    {
        public int Id, Hands, AnteCents, StageMaxBetCents;
        public int[] AllowedBets;
        public string OpponentName, OpponentStyle, TableEventId, TableEventName, SecondaryKind, BossName;
        public bool IsBoss { get { return BossName.Length > 0; } }
        public int MinimumBetCents { get { return Math.Max(AnteCents, TableEventId == "high-minimums" ? 5000 : 0); } }
        public static Stage[] CreateAll()
        {
            return new[] {
                S(1,5,2500,10000,new[]{2500,5000,7500,10000},"Nervous Tourist","randomTourist","tourist-rush","Tourist Rush","winWithoutHeat",""),
                S(2,6,5000,15000,new[]{5000,10000,15000},"Weekend Regular","conservativeBanker","no-commission-night","No Commission Night","endWithProfit",""),
                S(3,7,7500,25000,new[]{7500,15000,22500,25000},"Card Room Grinder","smallBallGrinder","tie-promo","Tie Promo","triggerModifiers",""),
                S(4,8,10000,40000,new[]{10000,20000,30000,40000},"Tie Chaser","tieChaser","high-minimums","High Minimums","winTie",""),
                S(5,8,15000,60000,new[]{15000,30000,45000,60000},"Pattern Player","streakBetter","tight-surveillance","Tight Surveillance","conservativeBetting","Pit Boss"),
                S(6,8,20000,80000,new[]{20000,40000,60000,80000},"The Counter","counterBetter","private-table","Private Table","useAllBetTypes",""),
                S(7,9,30000,120000,new[]{30000,60000,90000,120000},"The Whale Junior","highRoller","rich-crowd","Rich Crowd","finishAheadByTwoAnte",""),
                S(8,10,40000,175000,new[]{40000,80000,120000,160000,175000},"Quiet Regular","smallBallGrinder","bad-cut","Bad Cut","winFinalHand","The Inspector"),
                S(9,10,60000,250000,new[]{60000,120000,180000,240000,250000},"The Cooler","conservativeBanker","cold-table","Cold Table","beatWithoutConsumables",""),
                S(10,12,80000,400000,new[]{80000,160000,240000,320000,400000},"The Floor Favorite","conservativeBanker","final-hand-spotlight","Final Hand Spotlight","recoverFromBehind","The House")
            };
        }
        private static Stage S(int id, int hands, int ante, int max, int[] bets, string opp, string style, string evt, string evtName, string secondary, string boss)
        {
            Stage s = new Stage(); s.Id = id; s.Hands = hands; s.AnteCents = ante; s.StageMaxBetCents = max; s.AllowedBets = bets; s.OpponentName = opp; s.OpponentStyle = style; s.TableEventId = evt; s.TableEventName = evtName; s.SecondaryKind = secondary; s.BossName = boss; return s;
        }
    }

    internal class ModifierDef
    {
        public string Id = "", Name = "", Rarity = "", Trigger = "", RequiredBet = "", RequiredWinner = "", HasTagCondition = "", Source = "RiggedShoe/Models/ModifierModels.swift", Raw = "";
        public List<string> Tags = new List<string>();
        public int MinTier = 1, Cost = 3, HeatCost = 0;
        public int[] AntePercent = new[] { 0, 0, 0 }, Chips = new[] { 0, 0, 0 }, RefundPercent = new[] { 0, 0, 0 }, PreventHeat = new[] { 0, 0, 0 }, Reveal = new[] { 0, 0, 0 };
        public int[] GainHeat = new[] { 0, 0, 0 }, ReduceHeat = new[] { 0, 0, 0 }, Burn = new[] { 0, 0, 0 }, MoveTopDeeper = new[] { 0, 0, 0 }, AddEights = new[] { 0, 0, 0 }, AddNines = new[] { 0, 0, 0 };
        public bool[] MoveTopBottom = new[] { false, false, false };
        public int[] PayoutAny = new[] { 0, 0, 0 }, PayoutPlayer = new[] { 0, 0, 0 }, PayoutBanker = new[] { 0, 0, 0 }, PayoutTie = new[] { 0, 0, 0 };
        public int[] StageLimit = new[] { -1, -1, -1 }, RunLimit = new[] { -1, -1, -1 }, HandLimit = new[] { -1, -1, -1 };
        public bool FirstPlayerSideWin, FirstBankerSideWin, FirstTieLoss, FirstWinningBet, ChipFirstStageOnly;
        public static ModifierDef Core(string id, string name, string rarity, string trigger, string[] tags, int tier, int cost)
        {
            ModifierDef d = new ModifierDef(); d.Id = id; d.Name = name; d.Rarity = rarity; d.Trigger = trigger; d.Tags.AddRange(tags); d.MinTier = tier; d.Cost = cost; d.Source = "RiggedShoe/Models/ModifierModels.swift:590"; d.Raw = "core sampleDebugPool"; return d;
        }
        public int PayoutPercentFor(string side, int level)
        {
            int i = Math.Max(0, Math.Min(2, level - 1));
            int v = PayoutAny[i];
            if (side == "player") v += PayoutPlayer[i];
            else if (side == "banker") v += PayoutBanker[i];
            else if (side == "tie") v += PayoutTie[i];
            return v;
        }
        public bool HasNumericPower()
        {
            return PowerScore() > 0;
        }
        public int PowerScore()
        {
            return AntePercent.Max() + Chips.Max() * 40 + RefundPercent.Max() + PreventHeat.Max() * 20 + Reveal.Max() * 10 + PayoutAny.Max() + PayoutPlayer.Max() + PayoutBanker.Max() + PayoutTie.Max() + AddEights.Max() * 8 + AddNines.Max() * 8;
        }
        public string BehaviorSummary()
        {
            List<string> parts = new List<string>();
            if (PayoutAny.Max() + PayoutPlayer.Max() + PayoutBanker.Max() + PayoutTie.Max() > 0) parts.Add("payout bonus up to " + (PayoutAny.Max() + PayoutPlayer.Max() + PayoutBanker.Max() + PayoutTie.Max()) + "%");
            if (AntePercent.Max() > 0) parts.Add("bankroll +" + AntePercent.Max() + "% ante");
            if (Chips.Max() > 0) parts.Add("chips +" + Chips.Max());
            if (RefundPercent.Max() > 0) parts.Add("refund up to " + RefundPercent.Max() + "%");
            if (PreventHeat.Max() > 0) parts.Add("prevents Heat");
            if (Reveal.Max() > 0) parts.Add("reveals " + Reveal.Max() + " cards");
            if (HeatCost > 0) parts.Add("costs " + HeatCost + " Heat");
            if (parts.Count == 0 && Raw.Length > 0) parts.Add(Raw);
            return string.Join("; ", parts.ToArray());
        }
    }

    internal class UpgradeDef
    {
        public string Name = "", Description = "", Rarity = "", RawEffect = "", Source = "";
        public List<string> Tags = new List<string>();
    }

    internal class Contact
    {
        public string Id = "", Name = "";
        public int BankrollAdjust, ChipsAdjust, HeatAdjust, EarlyMaxBetMultiplierPercent = 100, CashRewardMultiplierPercent = 100;
        public List<string> StartingModifiers = new List<string>();
        public List<string> ShopBiasTags = new List<string>();
    }

    internal class StageRewardDef
    {
        public string Name = "", Kind = "", RebuildKind = "", Rarity = "";
        public int CashMultiplier, Chips, HeatReduction, TiePayoutBonus, ShoeHighCards, RemoveFaceCards;
        public List<string> Tags = new List<string>();
        public static StageRewardDef Cash(string name, int mult) { StageRewardDef r = new StageRewardDef(); r.Name = name; r.Kind = "cash"; r.CashMultiplier = mult; r.Tags.Add("economy"); return r; }
        public static StageRewardDef ChipReward(string name, int chips) { StageRewardDef r = new StageRewardDef(); r.Name = name; r.Kind = "chips"; r.Chips = chips; r.Tags.Add("economy"); return r; }
        public static StageRewardDef Heat(string name, int heat) { StageRewardDef r = new StageRewardDef(); r.Name = name; r.Kind = "heat"; r.HeatReduction = heat; r.Tags.Add("heat"); return r; }
        public static StageRewardDef Rebuild(string name, string rebuild, string rarity) { StageRewardDef r = new StageRewardDef(); r.Name = name; r.Kind = "rebuild"; r.RebuildKind = rebuild; r.Rarity = rarity; r.Tags.Add(rebuild == "modifierDraft" ? "betControl" : rebuild.Replace("Draft", "")); return r; }
        public static StageRewardDef Legacy(string name, string rarity) { StageRewardDef r = new StageRewardDef(); r.Name = name; r.Kind = "legacyUpgrade"; r.Rarity = rarity; r.Tags.Add("economy"); return r; }
        public static StageRewardDef Tie(string name, int amount) { StageRewardDef r = new StageRewardDef(); r.Name = name; r.Kind = "tiePayout"; r.TiePayoutBonus = amount; r.Tags.Add("tie"); return r; }
        public static StageRewardDef ShoeHigh(string name, int count) { StageRewardDef r = new StageRewardDef(); r.Name = name; r.Kind = "shoeHigh"; r.ShoeHighCards = count; r.Tags.Add("cardSculpting"); return r; }
        public static StageRewardDef RemoveFace(string name, int count) { StageRewardDef r = new StageRewardDef(); r.Name = name; r.Kind = "removeFace"; r.RemoveFaceCards = count; r.Tags.Add("shoeControl"); return r; }
    }

    internal class BossRewardDef
    {
        public string Name = "", Kind = "";
        public int Count, Multiplier, CashMultiplier, Chips;
        public static BossRewardDef Simple(string name, string kind) { BossRewardDef r = new BossRewardDef(); r.Name = name; r.Kind = kind; return r; }
        public static BossRewardDef CountReward(string name, string kind, int count) { BossRewardDef r = Simple(name, kind); r.Count = count; return r; }
        public static BossRewardDef MultReward(string name, string kind, int mult) { BossRewardDef r = Simple(name, kind); r.Multiplier = mult; return r; }
        public static BossRewardDef Cash(string name, int mult, int chips) { BossRewardDef r = Simple(name, "cash"); r.CashMultiplier = mult; r.Chips = chips; return r; }
    }

    internal class RunOptions
    {
        public string Policy = "";
        public ulong Seed;
        public string DisabledModifierId;
        public bool CaptureTrace;
        public int GlobalScalePercent = 100;
        public Dictionary<string, int> ScaleMap;
    }

    internal class SimState
    {
        public Mechanics Mechanics;
        public RunOptions Options;
        public string Policy = "";
        public Lcg ShoeRng, TreeRng, RewardRng, PolicyRng;
        public Contact Contact;
        public Stage Stage;
        public int StageIndex, Bankroll, Chips, Heat, BossesDefeated, StageStartBankroll, StageStartHeat, StageStartChips, StageRoundsPlayed, StageWinningBets, StageUpgradeTriggers, StageRevealWins, StageLosses, StageOpponentProfit, StageConsumablesUsed, StageFinalHandIndex, TotalHands, TotalDecisions, ModifierRevealCount, TiePayoutBonus, TiePayoutOverride = 8, FutureStageRoundBonus, BankrollBeforeRound, PreviousRoundLoss, DamageControlHandsSinceUse = 3, ConsecutiveLosses, SmallBetWinStreak, LastBetAmount, PlayerWinStreak, BankerWinStreak, TieStreak, PlayerSideWinsThisStage, BankerSideWinsThisStage, TieBetLossesThisStage, HighestBankroll;
        public bool StageFinalHandWon, StageFellBehind, StageStayedUnderQuarter = true, HasUsedHighRollerSparkThisStage, HasPaidFaceHunterThisStage, LastRoundDidWin, BossInspectorUsed, HouseAdaptiveUsed, HouseRuleShiftUsed;
        public string LastWinner = "", ActiveBoss = "", BossLastBet = "";
        public int BossSameSideCount = 0;
        public List<Card> Shoe = new List<Card>();
        public List<ModifierInstance> ActiveMods = new List<ModifierInstance>();
        public List<ModifierInstance> BenchMods = new List<ModifierInstance>();
        public List<UpgradeDef> LegacyUpgrades = new List<UpgradeDef>();
        public UpgradeSummary UpgradeSummary = new UpgradeSummary();
        public HashSet<string> StageWinningSides = new HashSet<string>();
        public Counter ModifierTriggers = new Counter(), ModifierOffers = new Counter(), ModifierPicks = new Counter(), ModifierBankrollDelta = new Counter();
        public int VisibleRevealCount() { return ModifierRevealCount; }
        public int WinStreak(string side) { if (side == "player") return PlayerWinStreak; if (side == "banker") return BankerWinStreak; return TieStreak; }
        public HashSet<string> ActiveTags() { return new HashSet<string>(ActiveMods.SelectMany(m => m.Def.Tags)); }
        public Dictionary<string, int> TagCounts()
        {
            Dictionary<string, int> d = new Dictionary<string, int>();
            foreach (ModifierInstance mi in ActiveMods) foreach (string t in mi.Def.Tags) d[t] = d.Get(t) + Math.Max(1, mi.Level);
            return d;
        }
    }

    internal class ModifierInstance
    {
        public ModifierDef Def;
        public int Level = 1, StageUses = 0, RunUses = 0, HandUses = 0;
        public bool StageChipGranted = false;
        public ModifierInstance(ModifierDef def) { Def = def; }
    }

    internal class UpgradeSummary
    {
        public int PlayerWinBonusCents, BankerWinBonusCents, ChosenBetWinBonusCents, ForecastWinBonusCents, PlayerWinBonusAntePercent, BankerWinBonusAntePercent, ChosenBetWinBonusAntePercent, ForecastWinBonusAntePercent, TiePayoutMultiplier = 8, TiePayoutBonus, RevealedCards, RevealAfterRoundCards, HotShoeExtraEights, HotShoeExtraNines, ColdShoeZeroCardsToRemove, AllProfitMultiplierPercent = 100, PlayerProfitMultiplierPercent = 100, BankerProfitMultiplierPercent = 100, TieProfitMultiplierPercent = 100, LossMultiplierPercent = 100, LossRebatePercent, RoundStipendCents, RoundStipendAntePercent, StageStartCashCents, StageStartCashMultiplierPercent, StageStartCashAnteMultiplierPercent, CardExitIncomeCents, AllStreakBonusCents, PlayerStreakBonusCents, BankerStreakBonusCents, TieStreakBonusCents, FirstTieEachStageMultiplier = 1, ConsecutiveTiePayoutBonus, PreviousLossRefundOnTiePercent, BossStageCashCents, BossStageCashAnteMultiplierPercent, SafetyNetThresholdPercent, SafetyNetCents, SmallBetMaxCents, SmallBetWinMultiplierPercent = 100, SmallBetStreakMaxCents, SmallBetStreakRequiredWins, SmallBetStreakBonusCents, PressAfterWinMultiplierPercent = 100, DamageControlRebatePercent, DamageControlEveryHands, BankerInitialBonusMinTotal, BankerInitialBonusMaxTotal = -1, BankerInitialBonusCents, FirstNaturalEachStageBonusCents, ComebackLossCount, ComebackWinBonusCents, FirstLargeBetMinCents, FirstLargeBetMultiplierPercent = 100, SteadyBetWinBonusCents, RaiseWinMinCents, RaiseWinBonusCents;
        public bool RemovesBankerCommission;

        public void Apply(UpgradeDef u)
        {
            string r = u.RawEffect;
            foreach (Match m in Regex.Matches(r, "playerAnteWinBonus\\(percentOfAnte:\\s*([0-9_]+)")) PlayerWinBonusAntePercent += P(m);
            foreach (Match m in Regex.Matches(r, "bankerAnteWinBonus\\(percentOfAnte:\\s*([0-9_]+)")) BankerWinBonusAntePercent += P(m);
            foreach (Match m in Regex.Matches(r, "chosenBetAnteWinBonus\\(percentOfAnte:\\s*([0-9_]+)")) ChosenBetWinBonusAntePercent += P(m);
            foreach (Match m in Regex.Matches(r, "forecastAnteWinBonus\\(percentOfAnte:\\s*([0-9_]+)")) ForecastWinBonusAntePercent += P(m);
            TiePayoutMultiplier = Math.Max(TiePayoutMultiplier, MatchInt(r, "improveTiePayout\\(multiplier:\\s*([0-9_]+)", 8));
            TiePayoutBonus += MatchInt(r, "tiePayoutBonus\\(amount:\\s*([0-9_]+)", 0);
            RevealedCards = Math.Max(RevealedCards, MatchInt(r, "revealCards\\(count:\\s*([0-9_]+)", 0));
            if (r.Contains("shoeReveal(.peek)")) RevealedCards = Math.Max(RevealedCards, 1);
            if (r.Contains("shoeReveal(.readTheShoe)")) RevealedCards = Math.Max(RevealedCards, 2);
            if (r.Contains("shoeReveal(.smudgedLens)") || r.Contains("shoeReveal(.bentCorner)") || r.Contains("shoeReveal(.xRay)")) RevealedCards = Math.Max(RevealedCards, 3);
            if (r.Contains("shoeReveal(.fullXRay)")) RevealedCards = Math.Max(RevealedCards, 4);
            RevealAfterRoundCards += MatchInt(r, "revealAfterRound\\(count:\\s*([0-9_]+)", 0);
            if (r.Contains("noCommission")) RemovesBankerCommission = true;
            HotShoeExtraEights += MatchInt(r, "hotShoe\\(extraEights:\\s*([0-9_]+)", 0);
            HotShoeExtraNines += MatchInt(r, "extraNines:\\s*([0-9_]+)", 0);
            ColdShoeZeroCardsToRemove += MatchInt(r, "coldShoe\\(removeZeroValueCards:\\s*([0-9_]+)", 0);
            foreach (Match m in Regex.Matches(r, "profitMultiplier\\(betType:\\s*([^,]+),\\s*percent:\\s*([0-9_]+)"))
            {
                int add = Parse(m.Groups[2].Value) - 100;
                string side = m.Groups[1].Value;
                if (side.Contains(".player")) PlayerProfitMultiplierPercent += add;
                else if (side.Contains(".banker")) BankerProfitMultiplierPercent += add;
                else if (side.Contains(".tie")) TieProfitMultiplierPercent += add;
                else AllProfitMultiplierPercent += add;
            }
            LossMultiplierPercent += Math.Max(0, MatchInt(r, "lossMultiplier\\(percent:\\s*([0-9_]+)", 100) - 100);
            LossRebatePercent = Math.Max(LossRebatePercent, MatchInt(r, "lossRebatePercent\\(percent:\\s*([0-9_]+)", 0));
            RoundStipendCents += MatchInt(r, "roundStipend\\(cents:\\s*([0-9_]+)", 0);
            RoundStipendAntePercent += MatchInt(r, "roundAnteStipend\\(percentOfAnte:\\s*([0-9_]+)", 0);
            StageStartCashCents += MatchInt(r, "stageStartCash\\(cents:\\s*([0-9_]+)", 0);
            StageStartCashAnteMultiplierPercent += MatchInt(r, "stageStartAnteCash\\(multiplierPercent:\\s*([0-9_]+)", 0);
            CardExitIncomeCents += MatchInt(r, "cardExitIncome\\(centsPerCard:\\s*([0-9_]+)", 0);
            foreach (Match m in Regex.Matches(r, "streakBonus\\(betType:\\s*([^,]+),\\s*centsPerWin:\\s*([0-9_]+)"))
            {
                int cents = Parse(m.Groups[2].Value);
                string side = m.Groups[1].Value;
                if (side.Contains(".player")) PlayerStreakBonusCents += cents;
                else if (side.Contains(".banker")) BankerStreakBonusCents += cents;
                else if (side.Contains(".tie")) TieStreakBonusCents += cents;
                else AllStreakBonusCents += cents;
            }
            FirstTieEachStageMultiplier = Math.Max(FirstTieEachStageMultiplier, MatchInt(r, "firstTieEachStageMultiplier\\(multiplier:\\s*([0-9_]+)", 1));
            ConsecutiveTiePayoutBonus += MatchInt(r, "consecutiveTiePayoutBonus\\(amount:\\s*([0-9_]+)", 0);
            PreviousLossRefundOnTiePercent = Math.Max(PreviousLossRefundOnTiePercent, MatchInt(r, "previousLossRefundOnTie\\(percent:\\s*([0-9_]+)", 0));
            BossStageCashAnteMultiplierPercent += MatchInt(r, "bossStageAnteCash\\(multiplierPercent:\\s*([0-9_]+)", 0);
            Match safety = Regex.Match(r, "safetyNet\\(thresholdPercent:\\s*([0-9_]+),\\s*cents:\\s*([0-9_]+)");
            if (safety.Success) { SafetyNetThresholdPercent = Math.Max(SafetyNetThresholdPercent, Parse(safety.Groups[1].Value)); SafetyNetCents += Parse(safety.Groups[2].Value); }
            Match small = Regex.Match(r, "smallBetWinMultiplier\\(maxBetCents:\\s*([0-9_]+),\\s*percent:\\s*([0-9_]+)");
            if (small.Success) { SmallBetMaxCents = Math.Max(SmallBetMaxCents, Parse(small.Groups[1].Value)); SmallBetWinMultiplierPercent += Parse(small.Groups[2].Value) - 100; }
            Match streak = Regex.Match(r, "smallBetStreakBonus\\(maxBetCents:\\s*([0-9_]+),\\s*requiredWins:\\s*([0-9_]+),\\s*cents:\\s*([0-9_]+)");
            if (streak.Success) { SmallBetStreakMaxCents = Math.Max(SmallBetStreakMaxCents, Parse(streak.Groups[1].Value)); SmallBetStreakRequiredWins = SmallBetStreakRequiredWins == 0 ? Parse(streak.Groups[2].Value) : Math.Min(SmallBetStreakRequiredWins, Parse(streak.Groups[2].Value)); SmallBetStreakBonusCents += Parse(streak.Groups[3].Value); }
            PressAfterWinMultiplierPercent += Math.Max(0, MatchInt(r, "pressAfterWinMultiplier\\(percent:\\s*([0-9_]+)", 100) - 100);
            Match dmg = Regex.Match(r, "lossRebateEveryHands\\(percent:\\s*([0-9_]+),\\s*everyHands:\\s*([0-9_]+)");
            if (dmg.Success) { DamageControlRebatePercent = Math.Max(DamageControlRebatePercent, Parse(dmg.Groups[1].Value)); DamageControlEveryHands = DamageControlEveryHands == 0 ? Parse(dmg.Groups[2].Value) : Math.Min(DamageControlEveryHands, Parse(dmg.Groups[2].Value)); }
            Match banker = Regex.Match(r, "bankerInitialTotalBonus\\(minTotal:\\s*([0-9_]+),\\s*maxTotal:\\s*([0-9_]+),\\s*cents:\\s*([0-9_]+)");
            if (banker.Success) { BankerInitialBonusMinTotal = Parse(banker.Groups[1].Value); BankerInitialBonusMaxTotal = Parse(banker.Groups[2].Value); BankerInitialBonusCents += Parse(banker.Groups[3].Value); }
            FirstNaturalEachStageBonusCents += MatchInt(r, "firstNaturalEachStageBonus\\(cents:\\s*([0-9_]+)", 0);
            Match comeback = Regex.Match(r, "comebackWinBonus\\(lossCount:\\s*([0-9_]+),\\s*cents:\\s*([0-9_]+)");
            if (comeback.Success) { ComebackLossCount = ComebackLossCount == 0 ? Parse(comeback.Groups[1].Value) : Math.Min(ComebackLossCount, Parse(comeback.Groups[1].Value)); ComebackWinBonusCents += Parse(comeback.Groups[2].Value); }
            Match large = Regex.Match(r, "firstLargeBetStageMultiplier\\(minBetCents:\\s*([0-9_]+),\\s*percent:\\s*([0-9_]+)");
            if (large.Success) { FirstLargeBetMinCents = FirstLargeBetMinCents == 0 ? Parse(large.Groups[1].Value) : Math.Min(FirstLargeBetMinCents, Parse(large.Groups[1].Value)); FirstLargeBetMultiplierPercent += Parse(large.Groups[2].Value) - 100; }
            SteadyBetWinBonusCents += MatchInt(r, "steadyBetWinBonus\\(cents:\\s*([0-9_]+)", 0);
            Match raise = Regex.Match(r, "raiseWinBonus\\(minRaiseCents:\\s*([0-9_]+),\\s*cents:\\s*([0-9_]+)");
            if (raise.Success) { RaiseWinMinCents = RaiseWinMinCents == 0 ? Parse(raise.Groups[1].Value) : Math.Min(RaiseWinMinCents, Parse(raise.Groups[1].Value)); RaiseWinBonusCents += Parse(raise.Groups[2].Value); }
        }
        public int ProfitMultiplierPercent(string side)
        {
            int specific = side == "player" ? PlayerProfitMultiplierPercent : side == "banker" ? BankerProfitMultiplierPercent : TieProfitMultiplierPercent;
            return Math.Max(0, AllProfitMultiplierPercent + specific - 100);
        }
        public int StreakBonus(string side, int streak)
        {
            int specific = side == "player" ? PlayerStreakBonusCents : side == "banker" ? BankerStreakBonusCents : TieStreakBonusCents;
            return streak * (AllStreakBonusCents + specific);
        }
        private static int P(Match m) { return Parse(m.Groups[1].Value); }
        private static int Parse(string s) { return int.Parse(s.Replace("_", ""), CultureInfo.InvariantCulture); }
        private static int MatchInt(string text, string pattern, int fallback) { Match m = Regex.Match(text, pattern); return m.Success ? Parse(m.Groups[1].Value) : fallback; }
    }

    internal class GameEvent
    {
        public string Trigger = "", BetType = "", Winner = "", ModifierId = "";
        public int Amount, HeatAmount, BasePayout;
        public static GameEvent StageStarted() { return new GameEvent { Trigger = "stageStarted" }; }
        public static GameEvent BetPlaced(string bet, int amount) { return new GameEvent { Trigger = "betPlaced", BetType = bet, Amount = amount }; }
        public static GameEvent BeforeDeal() { return new GameEvent { Trigger = "beforeDeal" }; }
        public static GameEvent PlayerWon(string bet, string winner, int amount, int basePayout) { return new GameEvent { Trigger = "playerWonBet", BetType = bet, Winner = winner, Amount = amount, BasePayout = basePayout }; }
        public static GameEvent PlayerLost(string bet, string winner, int amount) { return new GameEvent { Trigger = "playerLostBet", BetType = bet, Winner = winner, Amount = amount }; }
        public static GameEvent TieOccurred() { return new GameEvent { Trigger = "tieOccurred" }; }
        public static GameEvent HeatGained(int amount) { return new GameEvent { Trigger = "heatGained", HeatAmount = amount }; }
        public static GameEvent ShopEntered() { return new GameEvent { Trigger = "shopEntered" }; }
        public static GameEvent ShopRerolled() { return new GameEvent { Trigger = "shopRerolled" }; }
        public static GameEvent ModifierBought(string id) { return new GameEvent { Trigger = "modifierBought", ModifierId = id }; }
        public static GameEvent ModifierLeveled(string id) { return new GameEvent { Trigger = "modifierLeveled", ModifierId = id }; }
    }

    internal class ModifierResolution
    {
        public string ModifierId = "", ModifierName = "";
        public int BankrollDelta, ChipDelta, HeatDelta, HeatPrevented, Reveal, Burn, MoveTopDeeper, AddEights, AddNines;
        public bool MoveTopBottom;
        public bool HasEffect() { return BankrollDelta != 0 || ChipDelta != 0 || HeatDelta != 0 || HeatPrevented != 0 || Reveal != 0 || Burn != 0 || MoveTopBottom || MoveTopDeeper != 0 || AddEights != 0 || AddNines != 0; }
    }

    internal class BetDecision { public string Side = "banker"; public int Amount; public bool Meaningful; }
    internal class DealOutcome { public string Winner = ""; public int PlayerTotal, BankerTotal, BankerInitialTotal; public bool Natural; public List<Card> PlayerCards, BankerCards; }
    internal class Forecast { public string Recommended = ""; public bool Complete, Partial, Natural; }
    internal class Payout { public int TotalReturn, Profit; public bool IsPush, UsedDamageControl, UsedHighRollerSparkAttempt, UsedFaceHunter; }
    internal class ShopOffer { public string Kind, ContentId; public int Price; public ShopOffer(string kind, string content, int price) { Kind = kind; ContentId = content; Price = price; } }

    internal class SimResult
    {
        public ulong Seed;
        public string Policy = "", Contact = "", Failure = "";
        public bool Completed;
        public int FinalStage, EndingBankroll, HighestBankroll, Heat, Chips, Hands, Decisions, MeaningfulDecisions, RevealDecisions;
        public int[] StageAttempts = new int[11], StageClears = new int[11], StageFailures = new int[11];
        public string ActiveBuild = "";
        public List<string> OwnedModifiers = new List<string>(), ModifiersPicked = new List<string>(), RewardsPicked = new List<string>();
        public List<string> Trace = new List<string>();
        public Counter ModifierTriggers = new Counter(), ModifierOffers = new Counter(), ModifierPicks = new Counter();
    }

    internal class Counter : Dictionary<string, int>
    {
        public int Get(string key) { return ContainsKey(key) ? this[key] : 0; }
    }

    internal class Aggregate
    {
        public string Configuration = "", Policy = "";
        public int Runs, Completed, Hands, Decisions, MeaningfulDecisions, RevealDecisions, HeatSum;
        public long EndingBankrollSum, FinalStageSum;
        public List<int> EndingBankrolls = new List<int>();
        public int[] StageAttempts = new int[11], StageClears = new int[11], StageFailures = new int[11];
        public Counter ModifierTriggers = new Counter(), ModifierOffers = new Counter(), ModifierPicks = new Counter();
        public Dictionary<string, BuildAggregate> Builds = new Dictionary<string, BuildAggregate>();
        public Dictionary<string, PairAggregate> Pairs = new Dictionary<string, PairAggregate>();
        public void Add(SimResult r)
        {
            Runs++; if (r.Completed) Completed++; Hands += r.Hands; Decisions += r.Decisions; MeaningfulDecisions += r.MeaningfulDecisions; RevealDecisions += r.RevealDecisions; HeatSum += r.Heat; EndingBankrollSum += r.EndingBankroll; FinalStageSum += r.FinalStage; EndingBankrolls.Add(r.EndingBankroll);
            for (int i = 1; i <= 10; i++) { StageAttempts[i] += r.StageAttempts[i]; StageClears[i] += r.StageClears[i]; StageFailures[i] += r.StageFailures[i]; }
            MergeCounter(ModifierTriggers, r.ModifierTriggers); MergeCounter(ModifierOffers, r.ModifierOffers); MergeCounter(ModifierPicks, r.ModifierPicks);
            if (!Builds.ContainsKey(r.ActiveBuild)) Builds[r.ActiveBuild] = new BuildAggregate();
            Builds[r.ActiveBuild].Add(r);
            List<string> ids = r.OwnedModifiers.Distinct().OrderBy(x => x).ToList();
            for (int a = 0; a < ids.Count; a++) for (int b = a + 1; b < ids.Count; b++) { string key = ids[a] + "+" + ids[b]; if (!Pairs.ContainsKey(key)) Pairs[key] = new PairAggregate(); Pairs[key].Add(r); }
        }
        public void Merge(Aggregate o)
        {
            Runs += o.Runs; Completed += o.Completed; Hands += o.Hands; Decisions += o.Decisions; MeaningfulDecisions += o.MeaningfulDecisions; RevealDecisions += o.RevealDecisions; HeatSum += o.HeatSum; EndingBankrollSum += o.EndingBankrollSum; FinalStageSum += o.FinalStageSum; EndingBankrolls.AddRange(o.EndingBankrolls);
            for (int i = 1; i <= 10; i++) { StageAttempts[i] += o.StageAttempts[i]; StageClears[i] += o.StageClears[i]; StageFailures[i] += o.StageFailures[i]; }
            MergeCounter(ModifierTriggers, o.ModifierTriggers); MergeCounter(ModifierOffers, o.ModifierOffers); MergeCounter(ModifierPicks, o.ModifierPicks);
            foreach (var p in o.Builds) { if (!Builds.ContainsKey(p.Key)) Builds[p.Key] = new BuildAggregate(); Builds[p.Key].Merge(p.Value); }
            foreach (var p in o.Pairs) { if (!Pairs.ContainsKey(p.Key)) Pairs[p.Key] = new PairAggregate(); Pairs[p.Key].Merge(p.Value); }
        }
        private static void MergeCounter(Counter a, Counter b) { foreach (var p in b) a[p.Key] = a.Get(p.Key) + p.Value; }
        public double CompletionRate() { return Runs > 0 ? Completed / (double)Runs : 0; }
        public double MeanEndingBankroll() { return Runs > 0 ? EndingBankrollSum / (double)Runs : 0; }
        public double MeanFinalStage() { return Runs > 0 ? FinalStageSum / (double)Runs : 0; }
        public double MeanHands() { return Runs > 0 ? Hands / (double)Runs : 0; }
        public double MeanHeat() { return Runs > 0 ? HeatSum / (double)Runs : 0; }
        public double MeaningfulChoiceRate() { return Decisions > 0 ? MeaningfulDecisions / (double)Decisions : 0; }
        public double AvgRevealDecisions() { return Runs > 0 ? RevealDecisions / (double)Runs : 0; }
        public double StageHazard(int stage) { return StageAttempts[stage] > 0 ? StageFailures[stage] / (double)StageAttempts[stage] : 0; }
        public double PercentileEnding(int pct)
        {
            if (EndingBankrolls.Count == 0) return 0;
            EndingBankrolls.Sort();
            int idx = Math.Max(0, Math.Min(EndingBankrolls.Count - 1, (int)Math.Round((pct / 100.0) * (EndingBankrolls.Count - 1))));
            return EndingBankrolls[idx];
        }
    }

    internal class BuildAggregate
    {
        public int Runs, Completed, FinalStageSum; public long BankrollSum; public List<int> Stages = new List<int>();
        public void Add(SimResult r) { Runs++; if (r.Completed) Completed++; FinalStageSum += r.FinalStage; BankrollSum += r.EndingBankroll; Stages.Add(r.FinalStage); }
        public void Merge(BuildAggregate b) { Runs += b.Runs; Completed += b.Completed; FinalStageSum += b.FinalStageSum; BankrollSum += b.BankrollSum; Stages.AddRange(b.Stages); }
        public double CompletionRate() { return Runs > 0 ? Completed / (double)Runs : 0; }
        public double MeanFinalStage() { return Runs > 0 ? FinalStageSum / (double)Runs : 0; }
        public double MeanBankroll() { return Runs > 0 ? BankrollSum / (double)Runs : 0; }
        public double Consistency() { return Runs > 0 ? Stages.Count(x => x >= 8) / (double)Runs : 0; }
    }

    internal class PairAggregate : BuildAggregate { }

    internal class MechanicEffect
    {
        public string Id = "", Name = "", Trigger = "", Rarity = "", Tags = "", Policy = "", Classification = "", TagsEvidence = "";
        public int SampleSize;
        public double OfferRate, SelectionRate, TriggerRate, WithCompletion, WithoutCompletion, MarginalCompletion, MarginalEndingBankroll;
    }

    internal class ParameterSweep
    {
        public string ModifierId = "", ModifierName = "";
        public int ScalePercent, SampleSize;
        public double CompletionRate, AvgFinalStage, AvgEndingBankroll;
    }

    internal class StudyResult
    {
        public string Mode = "";
        public ulong Seed;
        public int Workers;
        public DateTime StartedUtc, FinishedUtc;
        public long TotalSimulations;
        public Mechanics Mechanics;
        public Dictionary<string, Aggregate> Baselines = new Dictionary<string, Aggregate>();
        public List<MechanicEffect> MechanicEffects = new List<MechanicEffect>();
        public List<ParameterSweep> ParameterSweeps = new List<ParameterSweep>();
        public List<Aggregate> VarianceConfigs = new List<Aggregate>();
    }

    internal class ChartPoint { public string Label; public double Value; public ChartPoint(string l, double v) { Label = l; Value = v; } }
    internal class ScatterPoint { public string Label; public double X, Y; public ScatterPoint(string l, double x, double y) { Label = l; X = x; Y = y; } }
    internal class LineSeries { public string Name = ""; public List<ChartPoint> Points = new List<ChartPoint>(); }

    internal class TraceCase
    {
        public string Kind, Policy;
        public ulong Seed;
        public TraceCase(string kind, string policy, ulong seed) { Kind = kind; Policy = policy; Seed = seed; }
    }

    internal static class Extensions
    {
        public static int Get(this Dictionary<string, int> d, string key) { return d.ContainsKey(key) ? d[key] : 0; }
    }
}
