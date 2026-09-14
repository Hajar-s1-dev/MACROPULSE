<?php
// ============================================================
// MACROPULSE DASHBOARD - DIRECT MYSQL CONNECT (PORT 3307)
// ============================================================
$host = "127.0.0.1";
$user = "root";
$pass = "";
$db   = "macropulse";
$port = 3307; 

mysqli_report(MYSQLI_REPORT_ERROR | MYSQLI_REPORT_STRICT);

try {
    $conn = new mysqli($host, $user, $pass, $db, $port);
} catch (mysqli_sql_exception $e) {
    die("Connection failed: " . $e->getMessage());
}

// FETCH GLOBAL RISK SUMMARY
$global_risk = $conn->query("SELECT * FROM vw_global_risk")->fetch_assoc();

// FETCH MAJOR EVENTS
$major_events = $conn->query("SELECT * FROM vw_major_events ORDER BY significance_score DESC LIMIT 10");

// FETCH COMMODITY RISKS
$commodity_risks = $conn->query("SELECT * FROM vw_commodity_risk ORDER BY average_impact DESC LIMIT 5");

// FETCH SECTOR RISKS
$sector_risks = $conn->query("SELECT * FROM vw_sector_risk ORDER BY average_impact DESC LIMIT 5");

// FETCH COUNTRY EXPOSURE
$country_exposures = $conn->query("SELECT * FROM vw_country_exposure ORDER BY average_exposure DESC LIMIT 5");
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>MacroPulse // Real-Time Intelligence Dashboard</title>
    <!-- Tailwind CSS CDN -->
    <script src="https://cdn.tailwindcss.com"></script>
    <!-- Chart.js CDN -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        body { background-color: #0b0f19; color: #c9d1d9; font-family: 'Inter', sans-serif; }
        .card { background-color: #161b22; border: 1px solid #30363d; border-radius: 0.5rem; }
    </style>
</head>
<body class="p-6">

    <!-- HEADER -->
    <div class="flex justify-between items-center mb-6 border-b border-gray-800 pb-4">
        <div>
            <h1 class="text-2xl font-bold text-white tracking-wider flex items-center gap-2">
                <span class="text-red-500">MACROPULSE</span> // RISK INTELLIGENCE
            </h1>
            <p class="text-xs text-gray-400">Real-Time Geopolitical & Economic Impact Monitor</p>
        </div>
        <div class="flex items-center gap-3">
            <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-900 text-green-300">
                <span class="w-2 h-2 mr-1.5 bg-green-400 rounded-full animate-pulse"></span> SYSTEM LIVE
            </span>
        </div>
    </div>

    <!-- 1. KPI SUMMARY BARS (vw_global_risk) -->
    <div class="grid grid-cols-1 md:grid-cols-4 gap-4 mb-6">
        <div class="card p-4">
            <p class="text-xs text-gray-400 uppercase font-semibold">Total Major Events</p>
            <p class="text-3xl font-extrabold text-white mt-1"><?= $global_risk['total_major_events'] ?? 0 ?></p>
        </div>
        <div class="card p-4 border-l-4 border-red-500">
            <p class="text-xs text-gray-400 uppercase font-semibold">Global Threat Level</p>
            <p class="text-3xl font-extrabold text-red-400 mt-1"><?= $global_risk['global_events'] ?? 0 ?></p>
        </div>
        <div class="card p-4 border-l-4 border-orange-500">
            <p class="text-xs text-gray-400 uppercase font-semibold">Major Events</p>
            <p class="text-3xl font-extrabold text-orange-400 mt-1"><?= $global_risk['major_events'] ?? 0 ?></p>
        </div>
        <div class="card p-4 border-l-4 border-yellow-500">
            <p class="text-xs text-gray-400 uppercase font-semibold">Regional Events</p>
            <p class="text-3xl font-extrabold text-yellow-400 mt-1"><?= $global_risk['regional_events'] ?? 0 ?></p>
        </div>
    </div>

    <!-- 2. ANALYTICS GRID -->
    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6 mb-6">
        
        <!-- COMMODITY RISK (vw_commodity_risk) -->
        <div class="card p-5">
            <h3 class="text-sm font-bold text-white uppercase tracking-wider mb-4 border-b border-gray-800 pb-2">
                📦 Top Commodity Exposure
            </h3>
            <div class="space-y-4">
                <?php while($row = $commodity_risks->fetch_assoc()): ?>
                <div>
                    <div class="flex justify-between text-xs mb-1">
                        <span class="font-medium text-gray-200"><?= htmlspecialchars($row['commodity_name']) ?></span>
                        <span class="text-red-400 font-bold"><?= $row['average_impact'] ?>%</span>
                    </div>
                    <div class="w-full bg-gray-800 rounded-full h-2">
                        <div class="bg-red-500 h-2 rounded-full" style="width: <?= min(100, $row['average_impact']) ?>%"></div>
                    </div>
                </div>
                <?php endwhile; ?>
            </div>
        </div>

        <!-- SECTOR RISK (vw_sector_risk) -->
        <div class="card p-5">
            <h3 class="text-sm font-bold text-white uppercase tracking-wider mb-4 border-b border-gray-800 pb-2">
                🏢 Exposed Economic Sectors
            </h3>
            <div class="space-y-4">
                <?php while($row = $sector_risks->fetch_assoc()): ?>
                <div>
                    <div class="flex justify-between text-xs mb-1">
                        <span class="font-medium text-gray-200"><?= htmlspecialchars($row['sector_name']) ?></span>
                        <span class="text-orange-400 font-bold"><?= $row['average_impact'] ?>%</span>
                    </div>
                    <div class="w-full bg-gray-800 rounded-full h-2">
                        <div class="bg-orange-500 h-2 rounded-full" style="width: <?= min(100, $row['average_impact']) ?>%"></div>
                    </div>
                </div>
                <?php endwhile; ?>
            </div>
        </div>

        <!-- COUNTRY EXPOSURE (vw_country_exposure) -->
        <div class="card p-5">
            <h3 class="text-sm font-bold text-white uppercase tracking-wider mb-4 border-b border-gray-800 pb-2">
                🌍 Top Exposed Countries
            </h3>
            <div class="space-y-3">
                <?php while($row = $country_exposures->fetch_assoc()): ?>
                <div class="flex items-center justify-between p-2 rounded bg-gray-900 border border-gray-800">
                    <div>
                        <p class="text-xs font-bold text-white"><?= htmlspecialchars($row['country_name']) ?></p>
                        <p class="text-xs text-gray-500"><?= htmlspecialchars($row['region']) ?></p>
                    </div>
                    <span class="px-2 py-1 text-xs font-bold text-red-400 bg-red-950 border border-red-800 rounded">
                        Score: <?= $row['average_exposure'] ?>
                    </span>
                </div>
                <?php endwhile; ?>
            </div>
        </div>

    </div>

    <!-- 3. LIVE MAJOR EVENTS TABLE (vw_major_events) -->
    <div class="card p-5">
        <h3 class="text-sm font-bold text-white uppercase tracking-wider mb-4 border-b border-gray-800 pb-2">
            🚨 Live Critical Events Feed
        </h3>
        <div class="overflow-x-auto">
            <table class="w-full text-left text-xs text-gray-400">
                <thead class="bg-gray-900 text-gray-200 uppercase font-semibold">
                    <tr>
                        <th class="p-3">Global ID</th>
                        <th class="p-3">Actors</th>
                        <th class="p-3">Classification</th>
                        <th class="p-3">Significance</th>
                        <th class="p-3">Economic Risk</th>
                        <th class="p-3">Event Date</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-gray-800">
                    <?php while($event = $major_events->fetch_assoc()): ?>
                    <tr class="hover:bg-gray-900 transition-colors">
                        <td class="p-3 font-mono text-gray-300">#<?= $event['global_event_id'] ?></td>
                        <td class="p-3 font-medium text-white">
                            <?= htmlspecialchars($event['actor1_name'] ?: 'N/A') ?> 
                            <span class="text-gray-500">➔</span> 
                            <?= htmlspecialchars($event['actor2_name'] ?: 'N/A') ?>
                        </td>
                        <td class="p-3">
                            <span class="px-2 py-0.5 rounded text-xs font-semibold bg-blue-900 text-blue-300">
                                <?= $event['classification'] ?>
                            </span>
                        </td>
                        <td class="p-3 font-bold text-orange-400"><?= $event['significance_score'] ?> (<?= $event['significance_level'] ?>)</td>
                        <td class="p-3">
                            <span class="px-2 py-0.5 rounded text-xs font-bold 
                                <?= $event['economic_risk'] == 'CRITICAL' ? 'bg-red-900 text-red-200' : 'bg-yellow-900 text-yellow-200' ?>">
                                <?= $event['economic_risk'] ?>
                            </span>
                        </td>
                        <td class="p-3 text-gray-500"><?= $event['event_date'] ?></td>
                    </tr>
                    <?php endwhile; ?>
                </tbody>
            </table>
        </div>
    </div>

</body>
</html>