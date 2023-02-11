#!/usr/bin/env python3
#
# irtes_rc.py - iRTES Race Control
#
# 2023 Ryan Thompson <rjt@cpan.org>

from discord import interactions
import discord
from discord import app_commands
from baserow.client import BaserowClient
import configparser
import datetime
import os

intents = discord.Intents(
                      messages=True, 
               message_content=True, 
                       members=True, 
                        guilds=True)
bot     = discord.Client(intents=intents)
tree    = app_commands.CommandTree(bot)
conf    = configparser.ConfigParser()

conf.read('irtes_rc.ini')

guild   = discord.Object(id=conf['Discord']['Guild'])
baserow = BaserowClient('https://baserow.io', jwt=conf['Baserow']['jwt'])

#
# App Commands
#
@tree.command(
    name        = "irr",
    description = "Provides link to IRR form",
    guild       = guild)
async def irr_command(inter):
    embed = discord.Embed(
        title       = "CMS iRTES Incident Review Request Form",
        url         = conf['Discord']['IRRLink'],
        description = conf['Discord']['IRRDesc'],
        color       = discord.Color.red())
    embed.set_footer(text="Contact Ryan Thompson with feedback.")

    await inter.response.send_message(embed=embed)

#
# Other events
#
@bot.event
async def on_ready():
    await tree.sync(guild=guild)
    print('We have logged in as {0.user}'.format(bot))

@bot.event
async def on_message(message):
    if message.author == bot.user:
        return

    print('Received message: "{0.content}"'.format(message));


bot.run( conf['Discord']['Token'] )
