using UnityEngine;
using Cysharp.Threading.Tasks;
using System;
using System.IO;
using Newtonsoft.Json;
using UnityEngine.UI;

public class Baby
{
    public float Hunger { get; set; } = 100f; // 0-100, decreases over time
    public float Comfort { get; set; } = 100f;
    public float Stimulation { get; set; } = 100f;
    public int CurrentLeap { get; set; } = 1; // Start at Leap 1
    public float LeapProgress { get; set; } = 0f; // Progress through leap
}

public class Mother
{
    public float Energy { get; set; } = 100f; // 0-100
    public float Stress { get; set; } = 0f; // 0-100
}

namespace EasyMotherGame
{
    public class GameManager : MonoBehaviour
    {
        public Baby Baby { get; private set; }
        public Mother Mother { get; private set; }
        public float GameTime { get; private set; } = 0f; // Tracks game days
        private float timeScale = 60f; // 1 real minute = 1 game day

        // UI Elements
        public Slider hungerSlider, comfortSlider, stimulationSlider;
        public Slider energySlider, stressSlider;
        public Text leapText, timeText;

        private string savePath;

        void Start()
        {
            Baby = new Baby();
            Mother = new Mother();
            savePath = Path.Combine(Application.persistentDataPath, "save.json");
            LoadGame();
            UpdateUI();
            StartGameLoop().Forget();
        }

        async UniTaskVoid StartGameLoop()
        {
            while (true)
            {
                GameTime += Time.deltaTime / timeScale;
                UpdateNeeds();
                UpdateUI();
                await UniTask.DelayFrame(1); // Update every frame
            }
        }

        void UpdateNeeds()
        {
            // Decay baby needs
            Baby.Hunger = Mathf.Max(0, Baby.Hunger - 10f * Time.deltaTime / timeScale);
            Baby.Comfort = Mathf.Max(0, Baby.Comfort - 8f * Time.deltaTime / timeScale);
            Baby.Stimulation = Mathf.Max(0, Baby.Stimulation - 12f * Time.deltaTime / timeScale);

            // Decay mother stats
            Mother.Energy = Mathf.Max(0, Mother.Energy - 5f * Time.deltaTime / timeScale);
            Mother.Stress = Mathf.Min(100, Mother.Stress + 3f * Time.deltaTime / timeScale);

            // Check leap progress (example for Leap 1: sensory stimulation)
            if (Baby.Stimulation > 80f)
            {
                Baby.LeapProgress = Mathf.Min(100, Baby.LeapProgress + 5f * Time.deltaTime / timeScale);
            }
        }

        void UpdateUI()
        {
            hungerSlider.value = Baby.Hunger / 100f;
            comfortSlider.value = Baby.Comfort / 100f;
            stimulationSlider.value = Baby.Stimulation / 100f;
            energySlider.value = Mother.Energy / 100f;
            stressSlider.value = Mother.Stress / 100f;
            leapText.text = $"Leap {Baby.CurrentLeap}: {(Baby.LeapProgress)}%";
            timeText.text = $"Day {Mathf.FloorToInt(GameTime)}";
        }

        // Player actions
        public void FeedBaby()
        {
            if (Mother.Energy >= 10f)
            {
                Baby.Hunger = Mathf.Min(100, Baby.Hunger + 30f);
                Mother.Energy -= 10f;
                Mother.Stress += 5f;
                UpdateUI();
            }
        }

        public void SootheBaby()
        {
            if (Mother.Energy >= 8f)
            {
                Baby.Comfort = Mathf.Min(100, Baby.Comfort + 25f);
                Mother.Energy -= 8f;
                Mother.Stress += 3f;
                UpdateUI();
            }
        }

        public void PlayWithBaby()
        {
            if (Mother.Energy >= 12f)
            {
                Baby.Stimulation = Mathf.Min(100, Baby.Stimulation + 35f);
                Mother.Energy -= 12f;
                Mother.Stress += 4f;
                UpdateUI();
            }
        }

        public void MotherRest()
        {
            Mother.Energy = Mathf.Min(100, Mother.Energy + 20f);
            Mother.Stress = Mathf.Max(0, Mother.Stress - 15f);
            UpdateUI();
        }

        // Save game using JSON
        public async UniTask SaveGame()
        {
            var saveData = new { Baby, Mother, GameTime };
            string json = JsonConvert.SerializeObject(saveData, Formatting.Indented, new JsonSerializerSettings
            {
                ReferenceLoopHandling = ReferenceLoopHandling.Ignore,
                NullValueHandling = NullValueHandling.Ignore,
                Culture = System.Globalization.CultureInfo.InvariantCulture
            });

            await File.WriteAllTextAsync(savePath, json);
        }

        void LoadGame()
        {
            if (File.Exists(savePath))
            {
                // string json = File.ReadAllText(savePath);
                // var saveData = JsonConvert.DeserializeObject<dynamic>(json);
                // Baby.Hunger = saveData.Baby.Hunger;
                // Baby.Comfort = saveData.Baby.Comfort;
                // Baby.Stimulation = saveData.Baby.Stimulation;
                // Baby.CurrentLeap = saveData.Baby.CurrentLeap;
                // Baby.LeapProgress = saveData.Baby.LeapProgress;
                // Mother.Energy = saveData.Mother.Energy;
                // Mother.Stress = saveData.Mother.Stress;
                // GameTime = saveData.GameTime;
            }
        }

        void OnApplicationQuit()
        {
            SaveGame().Forget();
        }
    }
}