"""Wowhead link resolver — auto-detects wowhead URLs and embeds a clean preview."""

import logging

import discord
from discord.ext import commands

from config import SUPPORT_CHANNEL_IDS, CHANNEL_BUGREPORT
from wowhead import extract_wowhead_links
from emojis import em

log = logging.getLogger(__name__)

# Friendly names for entity types
ENTITY_LABELS = {
    "spell": "Spell",
    "item": "Item",
    "npc": "NPC",
    "quest": "Quest",
    "object": "Object",
    "achievement": "Achievement",
    "zone": "Zone",
}


class WowheadResolver(commands.Cog):
    """Auto-detects wowhead.com links and embeds a clean summary."""

    def __init__(self, bot: commands.Bot):
        self.bot = bot

    @commands.Cog.listener()
    async def on_message(self, message: discord.Message):
        if message.author.bot or not message.guild:
            return

        # Only resolve in support/bug channels
        target_channels = SUPPORT_CHANNEL_IDS | ({CHANNEL_BUGREPORT} if CHANNEL_BUGREPORT else set())
        if message.channel.id not in target_channels:
            return

        links = extract_wowhead_links(message.content)
        if not links:
            return

        # Limit to 5 links per message to avoid spam
        links = links[:5]
        lines = []

        for entity_type, entity_id in links:
            label = ENTITY_LABELS.get(entity_type, entity_type.title())
            icon = em("lookup", "\U0001f50d")
            url = f"https://www.wowhead.com/{entity_type}={entity_id}"
            lines.append(f"{icon} **{label}** `{entity_id}` — [View on Wowhead]({url})")

        if not lines:
            return

        embed = discord.Embed(
            description="\n".join(lines),
            color=discord.Color.blue(),
        )
        embed.set_footer(text=f"{em('watch', chr(0x1f441) + chr(0xfe0f))} Wowhead link detected")
        await message.reply(embed=embed, mention_author=False)
        log.info("Resolved %d wowhead links for %s", len(lines), message.author)


async def setup(bot: commands.Bot):
    await bot.add_cog(WowheadResolver(bot))
