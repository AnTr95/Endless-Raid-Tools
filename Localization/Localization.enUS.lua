EnRTLocals = {};
local L = EnRTLocals;
local addon = ...

L.OPTIONS_TITLE = "Endless Raid Tools"
L.OPTIONS_AUTHOR = "Author: " .. GetAddOnMetadata(addon, "Author") 
L.OPTIONS_VERSION = "Version: " .. GetAddOnMetadata(addon, "Version")
L.OPTIONS_INTERRUPT_TITLE = "Interrupt Module"
L.OPTIONS_ENABLED = "Enabled"
L.OPTIONS_INTERRUPT_ORDER = "Interrupt Order:(Seperated by comma)"
L.OPTIONS_INNERVATE_TITLE = "Innervate Module"
L.OPTIONS_CALENDARNOTIFICATION_TITLE = "Calendar Notifcation Module"
L.OPTIONS_DEMONICINQUISITION_TITLE = "Demonic Inquisition Module"
L.OPTIONS_MISTRESSSASSZINE_TITLE = "Mistress Sasszine Module"
L.OPTIONS_MAIDENOFVIGILANCE_TITLE = "Maiden of Vigilance Module"
L.OPTIONS_IMONARSOULHUNTER_TITLE = "Imonar the Soulhunter Module"
L.OPTIONS_FELHOUNDSSARGERAS_TITLE = "Felhounds of Sargeras Module"
L.OPTIONS_READYCHECK_TITLE = "Ready Check Module"
L.OPTIONS_BONUSROLL_TITLE = "Bonus Roll Module"
L.OPTIONS_GENERAL_TITLE = "General Options"
L.OPTIONS_DEMONICINQUISITION_INFO = "Puts a marker on players with Echoing Anguish whenever they are not within 8 yards of any other player and updates in realtime."
L.OPTIONS_MISTRESSSASSZINE_INFO = "Coded for the mythic version of this fight, marks the players who get hydra shot with star, circle, diamond or triangle and then assigns the raid evenly to soak it which means 1 player with shot + 2-4 soakers. Players in group 1 will be prioritized to soak star, group 2 to soak circle etc but there is no guarantee as it always assigns so there is 4 soakers, meaning if 4 players are in group 1 well then it will take the last person of group 1 to soak the star and then it fills up from group 2 etc. Players with bufferfish will not be assigned to soaking. There will be a text on each players screen telling them where to go. Modify the size and position of the popup text in the general settings!"
L.OPTIONS_MAIDENOFVIGILANCE_INFO = "Using the Endless strategy, this module assigns 12 players to soak orbs. 6 per side and 2 per lane, 1 in front and 1 behind. Tanks always become Ranged Inner, Healers becomes Ranged Middle/Outer. Ranged always implies you are soaking on the opposite side of your own infusion. So a healer with light infusion that gets Ranged Middle has to go soak the light orbs on the fel side in the middle lane behind the group. Dps will be assigned to soak Melee inner/middle/outer they stay on their side and the addon picks from group position so starts by picking dps in grp1 then grp2 then grp3 etc, raid leader is hard coded by Blizzard to always be raid1 which means that player will be most prioritized. In the intermission phase assignments will be put up on each players screen. Modify the size and position of the popup text in the general settings!"
L.OPTIONS_CALENDARNOTIFICATION_INFO = "On login a voice reads 'You have X amount of unanswered calendar invites' (only counting raid events). If you have no unanswered invites you get no notification."
L.OPTIONS_INTERRUPT_INFO = "Makes you create interrupt orders and tells the next person in the order to interrupt with a pop up on that players screen. Usage: Put the name of the person who is after you on interrupts. Modify the size and position of the popup text in the general settings!"
L.OPTIONS_INNERVATE_INFO = "Tells your druid that you need innervate with a popup on your druids screen! By macroing: /endlessinnervate PlayerName. Modify the size and position of the popup text in the general settings!"
L.OPTIONS_READYCHECK_INFO = "If you are in a raid and you are either AFK or decline a ready check you will get an ugly looking button that will tell your raid mates that you are ready once you press it. It is ugly so that you will get ready faster and press the button to make it go away ;)."
L.OPTIONS_IMONARSOULHUNTER_INFO = "Puts a star marker on the person with sleep canister and creates a popup on everyones screen who is within 10 yards of that player. Whenever there are no players within 8 yards healers will get a popup saying 'DISPEL'. All players within 10y also gets a marker on their head to indicate which players are too close to the sleep canister player. Modify the size and position of the popup text in the general settings!"
L.OPTIONS_FELHOUNDSSARGERAS_INFO = "Whenever you get Weight of Darkness you will send a message in say chat 'X MORE PLAYER(S) COME STACK' X is replaced with 1 or 2 depending on how many more you need within 8 yards of you"
L.OPTIONS_GENERAL_INFO = "This is the popup text that Interrupt, Innervate, Bonus Roll, Mistress, Maiden and Imonar Modules are using. Move the popup to anywhere you want on your screen and change the size after your preference."
L.OPTIONS_BONUSROLL_INFO = "Whenever you enter the latest raid a window is presented allowing you to tick the boxes of the bosses you want to coin and on which difficutly. Once the a boss is killed that you have ticked a popup will show reminding you to use your bonus roll. Modify the size and position of the popup text in the general settings!"
L.OPTIONS_INTERRUPT_TORRENT = "Count Arcane Torrent as an interrupt"
L.BONUSROLL_INFO = "Pick bosses to coin"
L.OPTIONS_MOTHER_TITLE = "MOTHER Module"
L.OPTIONS_MOTHER_INFO = "Puts a marker on players with Endemic Virus whenever they are not within 10 yards of any other player and updates in realtime and sends popups to healers telling them to dispell."
L.OPTIONS_HIGHTINKERMEKKATORQUE_TITLE = "High Tinker Mekkatorque Module";
L.OPTIONS_HIGHTINKERMEKKATORQUE_INFO = "Once shrunk during non-transition phase it assigns all shrunk player to a target whom they will send the disarm code to by using a custom made UI that shows up while shrunk. Players can press the buttons in the UI to make a text popup on their active targets screen displaying the color they should press. While in transition phase the assignment is made as players jump in to robots. Data is always sent to players active target it is adviced to target the assigned target by the addon but it does not restrict you to it meaning you can also send data to other players that are not your assigned target by simply targeting them. Modify the size and position of the popup text in the general settings!";