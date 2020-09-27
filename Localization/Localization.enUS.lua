EnRTLocals = {};
local L = EnRTLocals;
local addon = ...;

L.OPTIONS_TITLE = "Endless Raid Tools";
L.OPTIONS_AUTHOR = "Author: " .. GetAddOnMetadata(addon, "Author");
L.OPTIONS_VERSION = "Version: " .. GetAddOnMetadata(addon, "Version");
L.OPTIONS_DIFFICULTY = "Difficulty:"
L.OPTIONS_ENABLED = "Enabled";

L.OPTIONS_POPUPSETTINGS_TEXT = "Popup Text Settings";
L.OPTIONS_FONTSIZE_TEXT = "Font size:";
L.OPTIONS_FONTSLIDER_BUTTON_TEXT = "Move Popup Text";

L.OPTIONS_VERSIONCHECK_TEXT = "Version Check Raid Members";
L.OPTIONS_VERSIONCHECK_BUTTON_TEXT = "Check Raiders";

L.OPTIONS_INFOBOXSETTINGS_TEXT = "Infobox Settings";
L.OPTIONS_INFOBOX_BUTTON_TEXT = "Move Infobox Text";

L.OPTIONS_MINIMAP_CLICK = "Click to open the settings";
L.OPTIONS_MINIMAP_MODE_TEXT = "Show minimap button:";

L.OPTIONS_GENERAL_INFO = "This is the popup text that |cFF00FFFFInterrupt|r, |cFF00FFFFInnervate|r, |cFF00FFFFHuntsman Altimor|r, |cFF00FFFFLady Inerva Darkvein|r, |cFF00FFFFHungering Destroyer|r, |cFF00FFFFSludgefist|r and |cFF00FFFFStone Legion Modules|r are using. Move the popup to anywhere you want on your screen and change the size after your preference.";
L.OPTIONS_GENERALSETTINGS_TEXT = "General Settings:";
L.OPTIONS_GENERAL_TITLE = "General Options";

L.OPTIONS_INTERRUPT_TITLE = "Interrupt Module";
L.OPTIONS_INTERRUPT_ORDER = "Interrupt Order:(Seperated by comma)";
L.OPTIONS_INTERRUPT_INFO = "Makes you create interrupt orders and tells the next person in the order to interrupt with a pop up on that players screen.\n|cFF00FFFFUsage:|r Put the name of the person who is after you on interrupts.\n\n|cFF00FFFFConfig:|r The popup can be individually moved and resized in the general options.";
L.OPTIONS_INTERRUPT_PREVIEW = "|cFFFFFFFFPreview of the popup that appears on your screen when it is your turn to interrupt|r";
L.OPTIONS_INTERRUPT_TORRENT = "Count Arcane Torrent as an interrupt";

L.OPTIONS_INNERVATE_TITLE = "Innervate Module";
L.OPTIONS_INNERVATE_INFO = "Tells your druid that you need innervate with a popup on your druids screen! By macroing: |cFF00FFFF/endlessinnervate PlayerName|r.\n\n|cFF00FFFFConfig:|r The popup can be individually moved and resized in the general options.";
L.OPTIONS_INNERVATE_PREVIEW = "|cFFFFFFFFPreview of the popup that appears on the druids screen|r";

L.OPTIONS_CALENDARNOTIFICATION_TITLE = "Calendar Notice Module";
L.OPTIONS_CALENDARNOTIFICATION_INFO = "On login a voice reads 'You have X amount of unanswered calendar invites' (only counting raid events). If you have no unanswered invites you get no notification.";

L.OPTIONS_BONUSROLL_TITLE = "Bonus Roll Module";
L.OPTIONS_BONUSROLL_INFO = "|cFF00FFFFNotification:|r Whenever you enter the latest raid a window is presented allowing you to tick the boxes of the bosses you want to coin and on which difficulty. Once a boss is killed that you have ticked a popup will show reminding you to use your bonus roll.\n|cFF00FFFFBLP:|r It also adds a BLP tracker to Blizzard's bonus roll frame, after 6 failed rolls you are guaranteed an item.\nModify the size and position of the popup text in the general settings!";
L.OPTIONS_BONUSROLL_PREVIEW = "|cFFFFFFFFPreview of the popup that appears and the BLP tracker:|r";

L.OPTIONS_READYCHECK_TITLE = "Ready Check Module";
L.OPTIONS_READYCHECK_INFO = "|cFF00FFFFRaiders:|r If you are in a raid and you are either AFK or decline a ready check you will get a button show up on your screen that will inform the raid that you are ready once you press it.\n|cFF00FFFFRaid leader(sender):|r If you have this enabled and send a ready check a list will show up of players that are AFK/not ready after the Blizzard ready check finished that updates in real time as the players presses their EnRT ready button.";
L.OPTIONS_READYCHECK_PREVIEW = "|cFF00FFFFRaiders:|r\n|cFFFFFFFFPreview of the button that appears if you press not ready or AFK for a ready check.|r\n\n|cFF00FFFFRaid leader(sender):|r\n|cFFFFFFFFPreview of the list that appears for the players that pressed not ready or was AFK\nThe list updates in real time.|r";
L.OPTIONS_READYCHECK_FLASHING = "Flash EnRT Ready Check Button \nWarning for those sensitive to pulsating light.";

L.OPTIONS_CONSUMABLECHECK_PREVIEW = "|cFFFFFFFFPreview of consumable check from |cff3ec6eaMage|r PoV (can buff) and |cfff38bb9Paladin|r PoV (cant buff)|r";
L.OPTIONS_CONSUMABLECHECK_INFO = "Shows if the player has flask, weapon oil/sharpening stone, food and rune. In addition classes that can buff can see if players are missing their buff.\nThe top picture is taken from a |cff3ec6eamage|r point of view, other classes would see their buff or none if they do not have any.\nThe bottom picture is taken from a |cfff38bb9paladin|r which can not buff and therefore no buffs are shown.";
L.OPTIONS_CONSUMABLECHECK_TITLE = "Consumable Check Module";

L.OPTIONS_HUNGERINGDESTROYER_TITLE = "Hungering Dest. Module";
L.OPTIONS_HUNGERINGDESTROYER_INFO = "|cFF00FFFFMiasma|r Evenly distributes players for gluttonous miasma. INFO WIP Got 3 strategies unsure which one to use until Blizzard decides debuff damage.\n\n|cFF00FFFFConfig:|r The popup can be individually moved and resized in the general options.";
L.OPTIONS_HUNGERINGDESTROYER_PREVIEW = "";

L.OPTIONS_LADYINERVADARKVEIN_TITLE = "Inerva Darkvein Module";
L.OPTIONS_LADYINERVADARKVEIN_INFO = "|cFFFF0000Important!|r Make sure you are not using any other addons for marking Sins and Suffering.\n\n|cFF00FFFFSins and Suffering:|r Marks players with Sins and Suffering pointing them to star, circle and diamond. Since the orbs spawns before the debuffs goes out the raid leader can use world marks to tell people where to go before the debuffs even goes out. The marks are prioritized based of raid index, group 1 player 1 is always going to get star for example if they get debuffed, group 1 player 2 will always get star unless player 1 got it etc etc. This makes it so that you can put melee in the lower raid indexes and always put star marker to the orb closest to the boss to reduce the distances that has to be walked.";

L.OPTIONS_COUNCILOFBLOOD_TITLE = "Council of Blood Module";
L.OPTIONS_COUNCILOFBLOOD_INFO = "|cFF00FFFFDanse Macabre:|r Makes the button glow of the correct dance move during Danse Macabre.\n|cfff2c501Action Button Support:|r Blizzard Action Buttons, Bartender4, ElvUI, ElvUI_SLE. Contact me about missing addon support.\n\n|cFF00FFFF(Mythic) Dancing Fever:|r Tells the classes that can dispel diseases (|cff00fe97Monk|r/|cfff38bb9Paladin|r/|cFFFFFFFFPriest|r) when it is safe to dispel dancing fever. All players still need to have the module enabled.\n\n|cFF00FFFFConfig:|r The popup can be individually moved and resized in the general options.";
L.OPTIONS_COUNCILOFBLOOD_DM = "Danse Macabre Enabled";
L.OPTIONS_COUNCILOFBLOOD_DF = "Dancing Fever Enabled";
L.OPTIONS_COUNCILOFBLOOD_PREVIEW = "|cFFFFFFFFPreview of the glowing buttons during Danse Macabre and dispel text for |cff00fe97Monk|r/|cfff38bb9Paladin|r/|cFFFFFFFFPriest|r";

L.OPTIONS_HUNTSMANALTIMOR_TITLE = "Huntsman Altimor Module";
L.OPTIONS_HUNTSMANALTIMOR_INFO = "|cFF00FFFFSummary:|r Evenly distributes players to soak Sinseeker, 3 soakers per line.\n|cFF00FFFFDetailed:|r The debuffed player should always be the furthest player. Always using the first 4 players in group 2, 3 and 4 to soak each player has a standard position.\n|cFF00FFFFAbbrevations:|r G=Group P=Player index in group B=Backup\n\n        ------G2P4B--G2P3--G2P2--G2P1--Star Debuff\nBOSS------G3P4B--G3P3--G3P2--G3P1--Circle Debuff\n        ------G4P4B--G4P3--G4P2--G4P1--Diamond Debuff\n\nBecause of the staggered application of debuffs might cause players to get reassigned in the case that one of the active soakers get debuffed. In the case of reassignment players will be prioritized closest to the boss to reduce distance.\n\n|cFF00FFFFConfig:|r The popup can be individually moved and resized in the general options.";
L.OPTIONS_HUNTSMANALTIMOR_PLAYERSPERLINE = "Amount of players per sinseeker incl. player targeted";
L.OPTIONS_HUNTSMANALTIMOR_PREVIEW = "|cFFFFFFFFPreview of the popup text and yell informing players of which mark to soak and their position or counting down if they have sinseeker themselves.|r";

L.OPTIONS_SLUDGEFIST_TITLE = "Sludgefist Module";
L.OPTIONS_SLUDGEFIST_INFO = "|cFF00FFFFFractured Boulder:|r Boulders spawn around the pillar that is destroyed by Hateful Gaze and you can predetermine marks for each of the corners i.e.\n|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_1:12|t=Back Right(SE), |TInterface\\TargetingFrame\\UI-RaidTargetingIcon_2:12|t=Back Left(SW), |TInterface\\TargetingFrame\\UI-RaidTargetingIcon_3:12|t=Front Right(NE) and |TInterface\\TargetingFrame\\UI-RaidTargetingIcon_4:12|t=Front Left(NW). The addon marks and assigns chain pairs to soak the boulders prioritizing tanks then healers then ranged. One person will be told to take both a large and then a small soak using a defensive while their partner will be told to just take a small soak. Players that gets assigned to soak will get a popup and start yelling their mark and what to soak when Sludgefist starts casting Hateful Gaze. The infobox used for |cFF00FFFFChain Link Range|r also shows information about the mark and what to soak as soon as chains goes out, giving players a lot of time to prepare for Hateful Gaze.\n\n|cFF00FFFFChain Link Range:|r All players get an infobox that informs you if you are more than 6 yards apart or not from the player you are chained to just as a warning.\n\n|cFF00FFFFConfig:|r The infobox and the popup can be individually moved and resized in the general options.";
L.OPTIONS_SLUDGEFIST_PREVIEW = "|cFFFFFFFFPreview of popup and yell which happens during gaze and the infobox which shows information ahead of time to give you time to prepare and shows a range check.|r";

L.OPTIONS_STONELEGIONGENERALS_TITLE = "Stone Legion Module";
L.OPTIONS_STONELEGIONGENERALS_INFO = "|cFF00FFFFHeart Rend:|r Assigns and orders healers to dispel players with Heart Rend debuffs and ensures they do not get assigned to themselves to prevent 2 stacks. Once a healer has been dispelled, a countdown is shown to indicate when the next healer in the order can dispel to prevent overlapping debuffs. The healer also gets a popup when its their turn to dispel.\n\n|cFF00FFFFConfig:|r The infobox and the popup can be individually moved and resized in the general options.";
L.OPTIONS_STONELEGIONGENERALS_PREVIEW = "|cFFFFFFFFPreview of the infobox that appears during Heart Rend with healers assigned to a debuffed player each and the countdown that begins after someone been dispelled as well as the popup that shows for the healer when its their time to dispel.";

L.BONUSROLL_INFO = "Pick bosses to coin";

L.WARNING_OUTOFDATEMESSAGE = "There is a newer version of Endless Raid Tools available on twitch/curse!";