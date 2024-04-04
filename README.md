# ![PatreonAntiLeak](/resources/PAL-Logo.png)

An attempt at curbing public archivers / leakers from allowing unauthorized access to digital work on Patreon (or any subscription based service) via means of data scraping / leaking URLs and publishing them without permission.

This solution utilizes the cloud drive platform [MEGA](https://mega.io/), [Discord](https://discord.com/) for more control over access and booting scrapers, and my automation script, [PAL](https://github.com/Katyatu/PatreonAntiLeak), to keep shared URLs fresh to only those with active subscriptions & expiring old URLs that might have been scraped and published unfairly.

## Methodology

  > "In every chain of reasoning, the evidence of the last conclusion can be no greater than that of the weakest link of the chain, whatever may be the strength of the rest." - Thomas Reid's Essays on the Intellectual Powers of Man, 1786

Using the concept of "A chain is only as strong as its weakest link", in order to help preserve exclusive access of digital work to authorized users only, one must eliminate as many weak links (vulnerabilities, workarounds, etc.) as possible. In the case of protecting the distribution of digital work, the centuries old "one way in, one way out, the path protected by guards" method would be the best place to start. Naturally, the first thing that came to mind utilizing this approach is...

A bank!

- **Discord** serves as the bank building with guards keeping an eye on activity, granting the ability to allow vault access to authorized customers, and removing anyone who jeopardizes vault security.
- **MEGA** serves as the vault itself, whose vault keys are rotated automatically under the discretion of the bank manager.
- **PAL** serves as an automated system of rotating vault keys in a publicly unknown frequency.<br/>(ie. invalidating potentially leaked keys and keeping authorized key holders up-to-date with the latest key)

Using this methodology, the ability to simply scrape URLs is rendered 99.9% pointless, as whatever the leaker unfairly publishes would be quickly invalidated per the set key rotation period.
<div align="right"><a href="https://github.com/Katyatu/PatreonAntiLeak/wiki/Methodology">Read More &#10137;</a></div>

## PAL's Concept Flowchart

<details>

<summary>Click here to show</summary>

![PatreonAntiLeak logo](/resources/PAL-Process.png)

</details>

## To Do:

With the completion of <ins>PAL v1.0</ins>, I will be more focused on documentation so that even the most technologically illiterate person will be able to successfully use PAL. Every digital artist deserves the ability to at least try to protect their work.
- [ ] Walk-through guides & wiki
- [ ] Example GIF
- [ ] Idiot-proof & make everything zero knowledge user friendly

## Targeted System Setup:

- Hardware: [Raspberry Pi Zero 2 W](https://www.raspberrypi.com/products/raspberry-pi-zero-2-w/)

  > A shopping list guide is planned

- OS: [Raspberry Pi OS Lite (64bit) - Debian 12](https://downloads.raspberrypi.com/raspios_lite_arm64/images/raspios_lite_arm64-2024-03-15/2024-03-15-raspios-bookworm-arm64-lite.img.xz)

  > Guide: [Getting started with your Raspberry Pi](https://www.raspberrypi.com/documentation/computers/getting-started.html)

## External Requirements:

- An account [registered](https://mega.nz/register) with MEGA
- Your [Discord Webhook Bot(s)](https://support.discord.com/hc/en-us/articles/228383668-Intro-to-Webhooks) setup inside your Discord server channel(s)

## Usage:

#### Installing Required Dependancies

    sudo apt update &&              # Update system repos \
    sudo apt -y full-upgrade &&     # Install any outstanding updates \
    sudo apt -y install jq &&       # Install jq Command-line JSON processor \
    sudo apt -y install megacmd     # Install MEGA's Command-line tool

> If you get an "E: Unable to locate package megacmd", you are missing MEGA's repository. Go to https://mega.io/cmd#download and download/install the package that targets your system.
  
> If you are using the **Targeted System Setup**, simply run the following command and you'll be set:

    wget https://mega.nz/linux/repo/Raspbian_11/armhf/megacmd-Raspbian_11_armhf.deb &&    # Fetch latest MEGAcmd package \
    sudo apt -y install "$PWD/megacmd-Raspbian_11_armhf.deb" &&    # Install MEGAcmd package \
    rm "$PWD/megacmd-Raspbian_11_armhf.deb"    # Delete MEGAcmd package

#### Log into MEGAcmd (PAL prerequisite)

    mega-login <email> <password>

#### Installing PAL

    wget -q https://raw.githubusercontent.com/Katyatu/PatreonAntiLeak/main/scripts/PAL-installer.sh &&     # Fetch installer script from here \
    chmod +x PAL-installer.sh &&     # Make installer script executable \
    ./PAL-installer.sh &&            # Run installer script \
    rm PAL-installer.sh              # Delete installer script

#### Optional: Enable plug-n-play

> By OS default, user services can't fire off until the user logs in first, either locally or via SSH. If your Raspberry Pi w/ PAL is fully set up, and you want PAL to autostart without needing to log in first (ie. connect the Pi to power, drop, and forget), then run the following command below. Otherwise, everytime you freshly boot your Pi, you will have to log in at least once to get PAL started.

    loginctl enable-linger <yourusername>

#### Running

    PAL-manager

## Disclaimer:

There may be fringe cases where unexpected errors happen, I try my best to account for every possible scenario and handle them accordingly. If I happen to miss one, let me know and I'll get it fixed.

## Legal Disclaimer:

I am not affiliated with any of the web services mentioned. This was written at the behest of some friends of mine who use Patreon and have complained about leakers / public archivers hurting their business.

## Contacts:

[Github](https://github.com/Katyatu)  
[Discord](https://discordapp.com/users/392501113611616267)
