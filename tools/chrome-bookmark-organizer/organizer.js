// Quick access items that stay on the bar (not moved into folders)
const QUICK_ACCESS = [
  { name: "WH", urlPat: "wowhead.com/" },
  { name: "TC", urlPat: "github.com/TrinityCore/TrinityCore" },
  { name: "Discord", urlPat: "discord.com/" },
  { name: "ChatGPT", urlPat: "chatgpt.com/" },
  { name: "Codex", urlPat: "chatgpt.com/codex" },
  { name: "Claude", urlPat: "claude.ai/" },
  { name: "Gemini", urlPat: "gemini.google.com/app" },
  { name: "Grok", urlPat: "grok.com/" },
];

function isQuickAccess(bm) {
  return QUICK_ACCESS.some(q => bm.title === q.name && bm.url.includes(q.urlPat));
}

// Folder definitions: name -> URL patterns
const FOLDERS = [
  ["AI Tools", [
    "midjourney.com", "127.0.0.1:8188", "lllyasviel/Fooocus", "aliveai.app",
    "seed.bytedance.com", "yupp.ai", "dreamina.capcut.com", "recraft.ai",
    "ohmplatform/FreedomGPT", "perchance.org", "topazlabs.com", "labs.google/fx",
    "openclaw.ai", "clawhub.ai", "gemini.google.com/app?utm_source", "prompthero.com",
  ]],
  ["AI Platforms & API", [
    "platform.claude.com", "aistudio.google.com", "console.cloud.google.com",
    "docs.cloud.google.com", "cloud.oracle.com", "labs.google.com/mariner",
    "claude.ai/chat/", "gemini.google.com/app/",
  ]],
  ["VoxCore Dev", [
    "cowork/outputs/roleplaycore-tracker", "voxcore84.github.io", "localhost:7681",
    "localhost:8765", "localhost:5000", "arctium.io", "localhost:5050", "wago.tools",
    "sniffing_pipeline_guide.html", "att_icons_export",
  ]],
  ["GitHub Repos", [
    "github.com/TrinityCore/ymir", "github.com/thorton1786", "github.com/coreretail6",
    "github.com/VoxCore84/tor-army", "github.com/VoxCore84/CreatureCodex",
    "github.com/ATTWoWAddon", "github.com/wowdev/wow-listfile", "github.com/BAndysc",
    "github.com/stoneharry", "github.com/Marlamin/DBC2CSV", "kruithne.net/wow.export",
    "github.com/Ghostopheles/Datamine", "github.com/Questie",
    "github.com/FuzzyStatic/blizzard", "github.com/McTalian",
    "github.com/Kruithne/spooder", "github.com/Kruithne/spooderverse", "bun.sh",
    "curseforge.com/wow/addons/narcissus", "curseforge.com/wow/addons/lastseen",
    "github.com/ccplugins", "github.com/disler",
    "github.com/GoogleChrome/lighthouse", "lighthouse-metrics.com",
    "developer.chrome.com/docs/lighthouse", "KamiliaBlow/RoleplayCore/pull/760",
    "gist.github.com/VoxCore84/528e801b", "gist.github.com/VoxCore84/22343664",
    "wago.io/browse/gse", "warcraftpets.com", "warperia.com",
    "community.developer.battle.net", "github.com/ZhengPeiRu21",
  ]],
  ["Claude Code Issues", [
    "anthropics/claude-code/issues",
    "web.archive.org/save/https://github.com/anthropics",
    "dev.to/voxcore84", "reddit.com/r/ClaudeAI", "gist.github.com/unkn0wncode",
  ]],
  ["WoW Guides", [
    "wowhead.com/guide", "wowhead.com/talent-calc", "wowhead.com/titles/pvp",
    "method.gg/guides", "reddit.com/r/wow/comments/1hrjp4s", "ownedcore.com",
    "azerothcore.org/wiki", "convertcsv.com", "epichosts.co.uk", "warspire.fpr.net",
    "trinitycore.info/install", "wowhead.com/items/armor/cosmetic",
    "wowhead.com/beta/items/armor/cosmetic", "wowhead.com/ptr-2/guide",
    "wowhead.com/cata/guide",
  ]],
  ["WoW Items & NPCs", [
    "wowhead.com/item=", "wowhead.com/npc=", "wowhead.com/achievement=",
    "wowhead.com/beta/outfit", "wowhead.com/outfit=",
  ]],
  ["Gaming", ["mobalytics.gg/diablo-4"]],
  ["Financial", ["chase.com", "americanexpress.com", "citidirect.com", "usaa.com"]],
  ["Personal & Legal", [
    "veritasmilitarylaw.com", "rainn.org", "safehelpline.org", "va.gov", "ssa.gov",
    "zenbusiness.com", "linkedin.com", "imgbb.com", "ecfr.gov", "chatgpt.com/c/",
  ]],
  ["Fitness & Health", [
    "reddit.com/r/BeyondPower", "unionfitness.com", "pliability.com", "wmfabrication.com",
    "youtube.com/watch?v=aO6F9MPYE4k", "youtube.com/watch?v=3U22w013uQY",
    "youtube.com/watch?v=oVOnXIiPgM8", "youtube.com/watch?v=X1I6lrGmgek",
    "youtube.com/watch?v=TSIbzfcnv_8", "ftstreaming.com",
    "starproviders.org", "deploymentpsych.org",
  ]],
  ["Hardware & Shopping", [
    "rog.asus.com", "newegg.com", "bellroy.com", "missionworkshop.com",
    "huckberry.com", "goruck.com",
  ]],
  ["NSFW", [
    "onlyfansadvice", "social-rise.com/blog/ai-onlyfans", "joylovedolls.com",
    "supercreator.app", "instantflow.ai", "pornhub.com", "civitai.com",
    "reddit.com/r/sdnsfw", "reddit.com/r/Entrepreneurs/comments/1ly6bos",
    "reddit.com/r/SaaS/comments/1jr7sbx",
    "reddit.com/r/StableDiffusion/comments/1amb4s8",
  ]],
  ["Entertainment", [
    "youtube.com/channel/UCNnKprAG", "hianime.to", "archive.org/",
    "youtube.com/watch?v=gR_f-iwUGY4",
  ]],
  ["Travel", ["hiltongrandvacations", "ovstravel.com"]],
  ["Fund Raising", [
    "pogo.org", "whistleblower.org", "vfw.org", "legion.org",
    "socialworkers.org", "spotfund.com", "crowdjustice.com", "gofundme.com",
  ]],
];

function categorize(bm) {
  const url = (bm.url || "").toLowerCase();
  if (isQuickAccess(bm)) return null; // don't move

  for (const [folderName, patterns] of FOLDERS) {
    for (const pat of patterns) {
      if (url.includes(pat.toLowerCase())) {
        return folderName;
      }
    }
  }
  return "Misc"; // uncategorized
}

const statusEl = document.getElementById("status");
function log(msg) {
  statusEl.textContent += msg + "\n";
  statusEl.scrollTop = statusEl.scrollHeight;
}

async function getBarId() {
  const tree = await chrome.bookmarks.getTree();
  // tree[0].children: [0]=Bookmarks Bar, [1]=Other Bookmarks
  return tree[0].children[0].id;
}

async function getOtherId() {
  const tree = await chrome.bookmarks.getTree();
  return tree[0].children[1].id;
}

async function getAllBookmarks(parentId) {
  const children = await chrome.bookmarks.getChildren(parentId);
  return children;
}

async function organize() {
  const btn = document.getElementById("run");
  btn.disabled = true;
  btn.textContent = "Working...";

  try {
    const barId = await getBarId();
    const otherId = await getOtherId();

    // Collect ALL url bookmarks from bar and other (including inside existing folders)
    const allBookmarks = [];
    const existingFolders = [];

    async function collectAll(parentId) {
      const children = await chrome.bookmarks.getChildren(parentId);
      for (const child of children) {
        if (child.url) {
          allBookmarks.push(child);
        } else {
          // It's a folder - collect its children too, then we'll remove the empty folder
          existingFolders.push(child);
          await collectAll(child.id);
        }
      }
    }

    await collectAll(barId);
    await collectAll(otherId);

    log(`Found ${allBookmarks.length} bookmarks and ${existingFolders.length} existing folders`);

    // Categorize each bookmark
    const plan = {}; // folderName -> [bookmark]
    let quickAccessCount = 0;

    for (const bm of allBookmarks) {
      const folder = categorize(bm);
      if (folder === null) {
        quickAccessCount++;
        continue; // Quick access - stays on bar
      }
      if (!plan[folder]) plan[folder] = [];
      plan[folder].push(bm);
    }

    log(`Quick access (staying on bar): ${quickAccessCount}`);
    log(`Categories: ${Object.keys(plan).length}`);

    // Create folders and move bookmarks
    // Use the defined order from FOLDERS, then Misc at the end
    const folderOrder = FOLDERS.map(f => f[0]);
    if (plan["Misc"]) folderOrder.push("Misc");

    let moved = 0;
    for (const folderName of folderOrder) {
      const bookmarks = plan[folderName];
      if (!bookmarks || bookmarks.length === 0) continue;

      // Check if folder already exists on bar
      const barChildren = await chrome.bookmarks.getChildren(barId);
      let folder = barChildren.find(c => !c.url && c.title === folderName);

      if (!folder) {
        folder = await chrome.bookmarks.create({ parentId: barId, title: folderName });
        log(`Created folder: ${folderName}`);
      }

      // Move bookmarks into folder
      for (const bm of bookmarks) {
        await chrome.bookmarks.move(bm.id, { parentId: folder.id });
        moved++;
      }
      log(`  ${folderName}: ${bookmarks.length} items moved`);
    }

    // Remove old empty folders (Fund Raising, Shopping list from Other, etc.)
    for (const ef of existingFolders) {
      try {
        const children = await chrome.bookmarks.getChildren(ef.id);
        if (children.length === 0) {
          await chrome.bookmarks.remove(ef.id);
          log(`Removed empty folder: ${ef.title}`);
        }
      } catch (e) {
        // Folder may have already been removed if it was nested
      }
    }

    log(`\nDone! Moved ${moved} bookmarks into folders.`);
    log("You can now remove this extension.");
    btn.textContent = "Done!";

  } catch (err) {
    log(`ERROR: ${err.message}`);
    btn.disabled = false;
    btn.textContent = "Retry";
  }
}

document.getElementById("run").addEventListener("click", organize);
