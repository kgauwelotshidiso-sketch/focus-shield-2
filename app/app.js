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
        return number + " Day";
    }

    return number + " Days";
}

function getStreakCount() {
    const streak = localStorage.getItem("streakCount");

    if (streak === null) {
        return 0;
    }

    return Number(streak);
}

function updateHomeStreak() {
    const homeStreak = document.getElementById("homeStreak");

    if (homeStreak) {
        homeStreak.textContent = formatDays(getStreakCount());
    }
}

function updateStreakForToday() {
    const today = getToday();
    const yesterday = getYesterday();

    const lastStreakDate = localStorage.getItem("lastStreakDate");
    let streakCount = getStreakCount();

    if (lastStreakDate === today) {
        return streakCount;
    }

    if (lastStreakDate === yesterday) {
        streakCount++;
    } else {
        streakCount = 1;
    }

    localStorage.setItem("streakCount", streakCount);
    localStorage.setItem("lastStreakDate", today);

    return streakCount;
}

updateHomeStreak();


document.getElementById("goalsBtn").addEventListener("click", function() {

    document.body.innerHTML = `
        <div class="container">
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
        </div>
    `;

    document.getElementById("backBtn").addEventListener("click", function() {
        location.reload();
    });

});


document.getElementById("timerBtn").addEventListener("click", function() {

    document.body.innerHTML = `
        <div class="container">
            <h1>Focus Timer</h1>

            <div class="card">
                <h2 id="timer">10:00</h2>
            </div>

            <button id="startBtn">Start</button>
            <button id="backBtn">Back</button>
        </div>
    `;

    let timeLeft = 600;
    let running = false;

    document.getElementById("startBtn").addEventListener("click", function() {

        if (running) return;
        running = true;

        const interval = setInterval(function() {

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

    document.getElementById("backBtn").addEventListener("click", function() {
        location.reload();
    });

});


document.getElementById("concentrationBtn").addEventListener("click", function() {

    document.body.innerHTML = `
        <div class="container">
            <h1>Concentration Trainer</h1>

            <div class="card">
                <h2>Affirmation</h2>
                <p>"I pause, I listen, and I follow my dreams."</p>
            </div>

            <button id="backBtn">Back</button>
        </div>
    `;

    document.getElementById("backBtn").addEventListener("click", function() {
        location.reload();
    });

});


document.getElementById("progressBtn").addEventListener("click", function() {

    const today = getToday();
    const savedDate = localStorage.getItem("listeningDate");

    if (savedDate !== today) {
        localStorage.setItem("listeningCount", 0);
        localStorage.setItem("listeningDate", today);
    }

    let savedCount = localStorage.getItem("listeningCount");

    if (savedCount === null) {
        savedCount = 0;
    } else {
        savedCount = Number(savedCount);
    }

    let streakCount = getStreakCount();
    const lastStreakDate = localStorage.getItem("lastStreakDate");

    document.body.innerHTML = `
        <div class="container">
            <h1>Progress Tracker</h1>

            <div class="card">
                <h2>Listening Practice Today</h2>
                <h3 id="listeningCount">${savedCount}</h3>
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

            <button id="addListeningBtn">+ Add Listening Win</button>
            <button id="resetListeningBtn">Reset Today</button>
            <button id="backBtn">Back</button>
        </div>
    `;

    document.getElementById("addListeningBtn").addEventListener("click", function() {
        savedCount++;
        localStorage.setItem("listeningCount", savedCount);
        localStorage.setItem("listeningDate", today);

        const updatedStreak = updateStreakForToday();

        document.getElementById("listeningCount").textContent = savedCount;
        document.getElementById("streakCount").textContent = formatDays(updatedStreak);
        document.getElementById("streakStatus").textContent = "Completed today.";
    });

    document.getElementById("resetListeningBtn").addEventListener("click", function() {
        savedCount = 0;
        localStorage.setItem("listeningCount", savedCount);
        localStorage.setItem("listeningDate", today);

        document.getElementById("listeningCount").textContent = savedCount;
    });

    document.getElementById("backBtn").addEventListener("click", function() {
        location.reload();
    });

});