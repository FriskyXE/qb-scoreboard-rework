// Store for activity data
let activityData = {};

window.addEventListener("message", (event) => {
    switch (event.data.action) {
        case "open":
            openScoreboard(event.data);
            break;
        case "close":
            closeScoreboard();
            break;
        case "setup":
            setupScoreboard(event.data);
            break;
        case "update":
            updateScoreboard(event.data);
            break;
    }
});

const openScoreboard = (data) => {
    const scoreboard = document.getElementById("scoreboard");
    scoreboard.classList.remove("scoreboard-hidden");
    scoreboard.classList.add("scoreboard-visible");
    
    // Update player count
    updatePlayerCount(data.players, data.maxPlayers);
    
    // Update job counts
    updateJobCounts(data.currentCops || 0, data.currentEms || 0, data.currentMechanic || 0);
    
    // Update all activity statuses
    Object.entries(data.requiredCops).forEach(([category, info]) => {
        updateActivityStatus(category, info, data.currentCops);
    });
};

const closeScoreboard = () => {
    const scoreboard = document.getElementById("scoreboard");
    scoreboard.classList.remove("scoreboard-visible");
    scoreboard.classList.add("scoreboard-hidden");
};

const updateScoreboard = (data) => {
    // Update player count
    updatePlayerCount(data.players, data.maxPlayers);
    
    // Update job counts
    updateJobCounts(data.currentCops || 0, data.currentEms || 0, data.currentMechanic || 0);
    
    // Update all activity statuses
    Object.entries(data.requiredCops).forEach(([category, info]) => {
        updateActivityStatus(category, info, data.currentCops);
    });
};

const setupScoreboard = (data) => {
    activityData = data.items;
    const content = document.getElementById("scoreboard-content");
    if (!content) return;
    
    content.innerHTML = "";
    
    // Add section title
    const sectionTitle = document.createElement("div");
    sectionTitle.className = "px-6 py-3 bg-zinc-800/30 border-y border-zinc-700/50";
    sectionTitle.innerHTML = `
        <h3 class="text-zinc-400 text-xs font-semibold uppercase tracking-wider flex items-center gap-2">
            <i class="fas fa-list-check"></i>
            Available Activities
        </h3>
    `;
    content.appendChild(sectionTitle);
    
    // Create activity items
    Object.entries(data.items).forEach(([key, value], index) => {
        const item = createActivityItem(key, value.label, value.icon, index);
        content.appendChild(item);
    });
};

const createActivityItem = (key, label, icon, index) => {
    const item = document.createElement("div");
    item.className = "scoreboard-item px-6 py-3.5 flex items-center justify-between transition-smooth hover:bg-zinc-700/20 border-b border-zinc-700/30 last:border-b-0 animate-slide-in";
    item.style.animationDelay = `${index * 0.05}s`;
    item.setAttribute("data-type", key);
    
    item.innerHTML = `
        <div class="flex items-center gap-3 flex-1">
            <div class="w-10 h-10 rounded-lg bg-zinc-800/80 flex items-center justify-center border border-zinc-700/50">
                <i class="fas ${icon} text-zinc-400"></i>
            </div>
            <div class="flex-1">
                <p class="text-zinc-100 font-semibold text-sm">${label}</p>
            </div>
        </div>
        <div class="status-icon-modern" data-status>
            <i class="fas fa-lock"></i>
        </div>
    `;
    
    return item;
};

const updateActivityStatus = (category, info, currentCops) => {
    const item = document.querySelector(`[data-type="${category}"]`);
    if (!item) return;
    
    const statusIcon = item.querySelector("[data-status]");
    
    if (!statusIcon) return;
    
    if (info.busy) {
        // Busy state
        statusIcon.className = "status-icon-modern status-busy-modern";
        statusIcon.innerHTML = '<i class="fas fa-hourglass-half"></i>';
    } else if (currentCops >= info.minimumPolice) {
        // Available state
        statusIcon.className = "status-icon-modern status-available-modern";
        statusIcon.innerHTML = '<i class="fas fa-circle-check"></i>';
    } else {
        // Unavailable state
        statusIcon.className = "status-icon-modern status-unavailable-modern";
        statusIcon.innerHTML = '<i class="fas fa-lock"></i>';
    }
};

const updatePlayerCount = (current, max) => {
    const playerCount = document.getElementById("player-count");
    if (playerCount) {
        playerCount.textContent = `${current}/${max}`;
    }
};

const updateJobCounts = (police, ems, mechanic) => {
    const policeCount = document.getElementById("police-count");
    const emsCount = document.getElementById("ems-count");
    const mechanicCount = document.getElementById("mechanic-count");
    
    if (policeCount) policeCount.textContent = police;
    if (emsCount) emsCount.textContent = ems;
    if (mechanicCount) mechanicCount.textContent = mechanic;
};
