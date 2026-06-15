document.addEventListener("DOMContentLoaded", function () {

    function getToday() {
        return new Date().toDateString();
    }

    function getYesterday() {
        const yesterday = new Date();
        yesterday.setDate(yesterday.getDate() - 1);
        return yesterday.toDateString();
    }

    function formatDays(number) {
        if (number === 1) {
            return "1 Day";
        }

        return number + " Days";
    }

    function getNumber(key) {
        return Number(localStorage.getItem(key) || 0);
    }

    function saveValue(key, value) {
        localStorage.setItem(key, value);
    }

    function updateLongestStreak(currentStreak) {
        let longestStreak = getNumber("longestStreakCount");

        if (currentStreak > longestStreak) {
            longestStreak = currentStreak;
            saveValue("longestStreakCount", longestStreak);
        }

        return longestStreak;
    }

    function updateHomeStats() {
        const currentStreak = getNumber("streakCount");
        const longestStreak = updateLongestStreak(currentStreak);

        const homeStreak = document.getElementById("homeStreak");
        const homeLongestStreak = document.getElementById("homeLongestStreak");

        if (homeStreak) {
            homeStreak.textContent = formatDays(currentStreak);
        }

        if (homeLongestStreak) {
            homeLongestStreak.textContent = formatDays(longestStreak);
        }
    }

    function updateStreakForToday() {
        const today = getToday();
        const yesterday = getYesterday();
        const lastStreakDate = localStorage.getItem("lastStreakDate");

        let streakCount = getNumber("streakCount");

        if (lastStreakDate === today) {
            return streakCount;
        }

        if (lastStreakDate === yesterday) {
            streakCount++;
        } else {
            streakCount = 1;
        }

        saveValue("streakCount", streakCount);
        saveValue("lastStreakDate", today);
        updateLongestStreak(streakCount);

        return streakCount;
    }

    function showPage(content) {
        document.body.innerHTML = `
            <div class="container">
                ${content}
            </div>
        `;
    }

    function goHome() {
        location.reload();
    }

    updateHomeStats();

    const goalsBtn = document.getElementById("goalsBtn");
    const timerBtn = document.getElementById("timerBtn");
    const concentrationBtn = document.getElementById("concentrationBtn");
    const progressBtn = document.getElementById("progressBtn");

    if (goalsBtn) {
        goalsBtn.addEventListener("click", function () {
            showPage(`
                <h1>My Goals</h1>

                <div class="card">
                    <h2>Listening Goal</h2>
                    <p>Wait for people to finish speaking before I respond.</p>
                </div>

                <div class="card">
                    <h2>Fitness Goal</h2>
                    <p>Build a fit body and stay disciplined.</p>
                </div>

                <button id="backBtn">Back</button>
            `);

            document.getElementById("backBtn").addEventListener("click", goHome);
        });
    }

    if (timerBtn) {
        timerBtn.addEventListener("click", function () {
            showPage(`
                <h1>Focus Timer</h1>

                <div class="card">
                    <h2 id="timer">10:00</h2>
                </div>

                <button id="startBtn">Start</button>
                <button id="backBtn">Back</button>
            `);

            let timeLeft = 600;
            let running = false;

            document.getElementById("startBtn").addEventListener("click", function () {
                if (running) return;

                running = true;

                const interval = setInterval(function () {
                    timeLeft--;

                    let minutes = Math.floor(timeLeft / 60);
                    let seconds = timeLeft % 60;

                    if (seconds < 10) {
                        seconds = "0" + seconds;
                    }

                    document.getElementById("timer").textContent = minutes + ":" + seconds;

                    if (timeLeft <= 0) {
                        clearInterval(interval);
                        alert("Focus Session Complete!");
                    }
                }, 1000);
            });

            document.getElementById("backBtn").addEventListener("click", goHome);
        });
    }

    if (concentrationBtn) {
        concentrationBtn.addEventListener("click", function () {
            showPage(`
                <h1>Concentration Trainer</h1>

                <div class="card">
                    <h2>Affirmation</h2>
                    <p>"I pause, I listen, and I follow my dreams."</p>
                </div>

                <button id="backBtn">Back</button>
            `);

            document.getElementById("backBtn").addEventListener("click", goHome);
        });
    }

    if (progressBtn) {
        progressBtn.addEventListener("click", function () {
            const today = getToday();
            const savedDate = localStorage.getItem("listeningDate");

            if (savedDate !== today) {
                saveValue("listeningCount", 0);
                saveValue("listeningDate", today);
            }

            let listeningCount = getNumber("listeningCount");
            let streakCount = getNumber("streakCount");
            let longestStreak = updateLongestStreak(streakCount);
            const lastStreakDate = localStorage.getItem("lastStreakDate");

            showPage(`
                <h1>Progress Tracker</h1>

                <div class="card">
                    <h2>Listening Practice Today</h2>
                    <h3 id="listeningCount">${listeningCount}</h3>
                    <p>Times I paused and listened before speaking.</p>
                    <p><strong>Today:</strong> ${today}</p>
                </div>

                <div class="card">
                    <h2>Current Streak</h2>
                    <h3 id="streakCount">${formatDays(streakCount)}</h3>
                    <p id="streakStatus">
                        ${lastStreakDate === today ? "Completed today." : "Add one listening win today to protect your streak."}
                    </p>
                </div>

                <div class="card">
                    <h2>Longest Streak</h2>
                    <h3 id="longestStreakCount">${formatDays(longestStreak)}</h3>
                    <p>Your best discipline streak so far.</p>
                </div>

                <button id="addListeningBtn">+ Add Listening Win</button>
                <button id="resetListeningBtn">Reset Today</button>
                <button id="backBtn">Back</button>
            `);

            document.getElementById("addListeningBtn").addEventListener("click", function () {
                listeningCount++;
                saveValue("listeningCount", listeningCount);
                saveValue("listeningDate", today);

                const updatedStreak = updateStreakForToday();
                const updatedLongestStreak = updateLongestStreak(updatedStreak);

                document.getElementById("listeningCount").textContent = listeningCount;
                document.getElementById("streakCount").textContent = formatDays(updatedStreak);
                document.getElementById("longestStreakCount").textContent = formatDays(updatedLongestStreak);
                document.getElementById("streakStatus").textContent = "Completed today.";
            });

            document.getElementById("resetListeningBtn").addEventListener("click", function () {
                listeningCount = 0;
                saveValue("listeningCount", listeningCount);
                saveValue("listeningDate", today);
                document.getElementById("listeningCount").textContent = listeningCount;
            });

            document.getElementById("backBtn").addEventListener("click", goHome);
        });
    }

});
