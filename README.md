# ![PatreonAntiLeak](/resources/PAL-Logo.png)

An attempt at curbing public archivers / leakers from allowing unauthorized access to digital work on Patreon (or any subscription based service) via means of data scraping / leaking URLs and publishing them without permission.

This solution utilizes the cloud drive platform [MEGA](https://mega.io/), [Discord](https://discord.com/) for more control over access and booting scrapers, and my automation script, [PAL](https://github.com/Katyatu/PatreonAntiLeak), to keep shared URLs fresh to only those with active subscriptions & expiring old URLs that might have been compromised.

Until Patreon releases a public API where one could programmatically edit Patreon posts, Discord is a required middleman for now.

## Methodology

> "In every chain of reasoning, the evidence of the last conclusion can be no greater than that of the weakest link of the chain, whatever may be the strength of the rest." - Thomas Reid's Essays on the Intellectual Powers of Man, 1786

Using the concept of "A chain is only as strong as its weakest link", in order to help preserve exclusive access of digital work to authorized users only, one must eliminate as many weak links (vulnerabilities, workarounds, etc.) as possible. In the case of protecting the distribution of digital work, the centuries old "one way in, one way out, the path protected by guards" method would be the best place to start. Naturally, the first thing that came to mind utilizing this approach is...

A bank!

- **Discord** serves as the bank building with guards keeping an eye on activity, granting the ability to allow vault access to authorized customers, and removing anyone who jeopardizes vault security.
- **MEGA** serves as the vault itself.
- **PAL** serves as an automated system of rotating vault keys under the discretion of the bank manager.<br/>(ie. invalidating potentially leaked keys and keeping authorized key holders up-to-date with the latest key)

Using this methodology, leaking URLs is rendered largely pointless, as any leaked URLs would be quickly invalidated per the set key rotation period.

<div align="right"><a href="https://github.com/Katyatu/PatreonAntiLeak/wiki/Methodology">Read More &#10137;</a></div>

## Concept Flowcharts

<details>
<summary><u>[Click]</u> How a local installation of PAL works</summary>

![PatreonAntiLeak logo](/resources/PAL-Process.png)

</details>

## To Do:

With the completion of <ins>PAL v1.0</ins>, I will be more focused on documentation so that anyone can use PAL with ease. Every digital artist deserves the ability to at least try to protect their work.

- [ ] Walk-through guides & wiki
- [ ] Example GIF
- [ ] Idiot-proof & make everything zero knowledge user friendly

Planned for <ins>PAL v1.1</ins>:
- [ ] Add option to separate encryption key from share link to break automated MEGA scraping
- [ ] Add operation to change encryption key of an instance's assigned folder

## Targeted System Setup:

- **Hardware:** [Raspberry Pi Zero 2 W](https://www.raspberrypi.com/products/raspberry-pi-zero-2-w/)

  > Shopping Guide (wip): [here](https://github.com/Katyatu/PatreonAntiLeak/wiki/Shopping-Guide)

- **OS:** [Raspberry Pi OS Lite (64bit) - Debian 12](https://downloads.raspberrypi.com/raspios_lite_arm64/images/raspios_lite_arm64-2024-03-15/2024-03-15-raspios-bookworm-arm64-lite.img.xz)
  > RPiOS Install Guide: [here](https://www.raspberrypi.com/documentation/computers/getting-started.html)

## External Requirements:

1. A [registered account with MEGA](https://mega.nz/register) that will serve as the vault to your digital work.

   > Free accounts start at 20GB, with up to 16TB paid storage.  
   > Pricing: [here](https://mega.io/pricing) | Privacy Policy: [here](https://tosdr.org/en/service/306)

2. A [Discord](https://discord.com/) server with dedicated channels that will serve as the gateway to your vault.

   > 'Tier 1' channel, that will contain a link (handled by PAL) to the 'Tier 1' folder on your MEGA drive.  
   > 'Tier 2' channel, that will contain a link (handled by PAL) to the 'Tier 2' folder on your MEGA drive.  
   > 'Tier \_' ... etc.

3. A Discord Webhook Bot per dedicated channel inside of your Discord server, already created and assigned to the appropriate cooresponding channel.

   > Discord Webhook Documentation: [here](https://support.discord.com/hc/en-us/articles/228383668-Intro-to-Webhooks)

## Usage:

#### Installing Required Dependencies

    sudo apt update &&              # Update system repos \
    sudo apt -y full-upgrade &&     # Install any outstanding updates \
    sudo apt -y install jq &&       # Install jq Command-line JSON processor \
    sudo apt -y install megacmd     # Install MEGA's Command-line tool

> If you get an "E: Unable to locate package megacmd", you are missing MEGA's repository.
>
> If you are using the **Targeted System Setup**, run the following command:
>
>     wget https://mega.nz/linux/repo/Raspbian_11/armhf/megacmd-Raspbian_11_armhf.deb &&    # Fetch latest MEGAcmd package \
>     sudo apt -y install "$PWD/megacmd-Raspbian_11_armhf.deb" &&    # Install MEGAcmd package \
>     rm "$PWD/megacmd-Raspbian_11_armhf.deb"    # Delete MEGAcmd package
>
> Otherwise, go to https://mega.io/cmd#download and download/install the package that targets your system.

<hr/>

#### Log into MEGAcmd (PAL prerequisite)

You have two ways to do this, pick one, both achieve the same result:

1.  Login inside of mega-cmd (more secure):

        mega-cmd

        login <email> <password>

        exit

2.  Login outside of mega-cmd:

        mega-login <email> <password>

<hr/>

#### Installing PAL

    wget -q https://raw.githubusercontent.com/Katyatu/PatreonAntiLeak/main/scripts/PAL-installer.sh &&     # Fetch installer script from here \
    chmod +x PAL-installer.sh &&     # Make installer script executable \
    ./PAL-installer.sh &&            # Run installer script \
    rm PAL-installer.sh              # Delete installer script

<hr/>

#### Optional: Enable plug-n-play (recommended)

By OS default, after a fresh reboot, the user must log in first before user services (like PAL-autostart.service) can be fired off. However, running the following command tells the system to waive the log in requirement, thus allowing user services to run their course as soon as they can after the system boots.

    loginctl enable-linger <yourusername>

Once this setting is set, and you have fully set up your local PAL instances, it becomes as simple as: RPi plugged into power = Your vault is PAL Protected; RPi unplugged from power = Your vault is not PAL Protected. Only time you would need to log into your RPi would be to manage instances or troubleshoot.

<hr/>

#### Running

    PAL-manager

## Disclaimer:

Since PAL is written purely in GNU's Bourne Again SHell, modifying your local PAL installation is possible. However, any degree of modification voids the privilege of you being able to open issues and/or complain. This repository will only be focused on the official version of PAL.

If you made a mod, have thoroughly tested it, and think it would serve as a respectable addition to the official PAL, you may post a request containing your code for me to review. Just don't get your hopes up.

There may be fringe cases where unexpected errors happen, I try my best to account for every possible scenario and handle them accordingly. If I happen to miss one, let me know and I'll get it fixed asap.

This project was born from the behest of some friends of mine who use Patreon and have complained about leakers / public archivers hurting their business. Also I couldn't sleep for \*\*\*\* one night and was feeling productive at the time.

## Legal Disclaimer:

I am not affiliated with any of the services mentioned within this project whatsoever.

## Contact:

[Github](https://github.com/Katyatu) - [Discord](https://discordapp.com/users/392501113611616267)
