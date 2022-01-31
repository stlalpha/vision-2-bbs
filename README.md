
# ViSiON/2 "The Resurrection"


![V2 Logo](https://github.com/stlalpha/vision-2-bbs/blob/main/IMAGES/welcome.png?raw=true)

## So what would you say you are doing around here?

This project is about re-resurrecting ViSiON/2 and allowing the world to experience the software themselves, and to expand and improve its capabilities.  

1. Its now sort ofy2k compliant until 2038.

2. It needs the full complement of early 90s period-correct artwork, as well as the assortment of third party tools and utilities to be complete

3. It needs its networked message bases, with a catchy period-correct name

4. Re-vamp filetransfers for a 2022 world, via a terminal

5. Its written in Turbo Pascal 6.  That should change.

## Releases ##
Source and Binary .zip- zipfile can be unzipped and run on real hardware or emulators.

Download the zipfile [here!](https://github.com/stlalpha/vision-2-bbs/releases)

***Do you docker?***

Prefer a docker image? [Snag it here!](https://github.com/stlalpha/docker-bbs-vision2)

## Do You Need Any Help With This?
Yes.  I need all the help.  Are you oddly interested in esoteric early 90s pre-internet bbs software and art?  Cool.  Contact me and let's work together.   [Contact me](mailto:stlalpha@vision2bbs.com) and lets work together.  Or don't and just send pull requests.  It'll be great either way.

## So where does it stand today?

***As of 25-Jan 2022***:

- Poorly hacked past the y2k (unsigned 16bit integer)  

- Functional zip archive suitable for running on actual hardware or on the emulation setup of your choice.  ***Needs a 16bit DOS subsystem to work.  Windows XP with netfoss and the included ZM.EXE will do you just right***

- You can get up and running right now using docker-compose:

This provides the full ViSiON/2 R1.0 setup in Drive G:

# Install and Run (docker)

You can install with:

    docker pull stlalpha/vision2bbsres

And run with:

    docker run -d -p 5901:5901 -p 23:23 --name bbs-v2 stlalpha/vision2bbsres


# Install and Run (docker-compose)

Save the following docker-compose.yml:
```

  ---
  version: "2.1"
  services:
   ViSiON-2:
     image: vision2bbsres
    container_name: bbs-v2
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=America/Chicago
      - VNCPASSWORD=muhbbspassword
    ports:
      - '23:23'
      - '5901:5901'
    restart: unless-stopped
```
And then...
```
bash$ docker-compose up -d
```

# Accessing and general commands

The image runs a VNC console on port 5901/tcp.  You can connect to this console with any VNC client, on the mac you can use "Screen Sharing" and point it at hostname:5901. 

By default, each invocation will generate a new VNC password.  To retrieve the current password, execute:

```
$ docker logs bbs-v2|grep password
```

## Social capital in the early digital world
As the BBS scene exploded throughout the 80s and 90s, there were hundreds (thousands?) of bbs programs created and released. This was pre-internet social media.  

They tended to be built by hobbyists who had a particular community they were looking to service.  Some of these programs were more tuned for message bases, some online games, but the most visually appealing (and in my opion, the most generally interesting) always were the ones that supported the underground scene (and later the art scene as it became more prominent and sophisticated).  They were generically known as "forum hacks", as they generally shared either a common ancestral source-code from another bbs [software](http://software.bbsdocumentary.com/IBM/DOS/FORUM/).

![V2 main stats](https://github.com/stlalpha/vision-2-bbs/blob/main/IMAGES/mainstats.png?raw=true)

The bulletin boards that ran these programs generally were prominent in the underground scene.  They tended to have multiple dial-up lines (internet access wasnt a thing most people had access to in the early 90s, and you wouldnt likely recognize it today even if you did), larger storage (measured in single-digit gigabytes), and typically didn't allow callers from their home area code.  


You generally had to know someone to get an account on these boards (some had a process where the existing users would view your application and decide themselves), some required you to upload sample files to show your worth.

You didn't use your real name on these boards, you used a handle, and as we were mostly teenagers and young adults, and mostly male, you can imagine the colorful assortment of names that showed up. 

![V2 credits](https://github.com/stlalpha/vision-2-bbs/blob/main/IMAGES/credits.png?raw=true)

If it was harder to get, more elusive or exclusive, it was viewed to have a higher value.  If you didn't know somone, you weren't going to run one of these.  Even if you did know someone, some of them limited the number of copies that could run in an area code. 

They had exlusive proprietary networked message boards.  You could post a message on one BBS, and if you called another bbs that was also in that network, your message would show up there as well and people there could respond to you.  The bbs's litearlly called each other and passed these messages back and forth.  Your network was cooler if it was harder to get in.   

This exclusivity was generally referred to as "Elite" or "Eliteness".  Harder to get?  More elite.  Elite > lame.

## ViSiON/2 - "Elite" Lineage

Source code tended to get out into the wild.  Forum hacks were primarily Pascal affairs, used [Turbo Technojock's](https://www.pcorner.com/list/PASCAL/TTT501-1.ZIP/INFO/) toolkit and a smorgasbord of copy pasta from all sorts of places.  Forum hacks proliferated and their growth seemed to accelerate once the ViSiON .82 sourcecode was released which I believe was around mid 1992.  

ViSiON (lower-cased i's were 'elite' for some reason when we were kids), was a forum hack, based off of leaked source-code of [LSD v1.21](http://software.bbsdocumentary.com/IBM/DOS/FORUM/).

So...

**[** FORUM **]** -> **[** LSD **]** -> **[** ViSiON **]**

ViSiON was written by Crimson Blade and The Elemental.

ViSiON/2 appears to be loosely derived from the ViSiON code, and was written by Crimson Blade circa 1992-1993.

So ViSiON/2's lineage...

**[** FORUM **]** -> **[** LSD **]** -> **[** ViSiON **]** -> **[** ViSiON/2 **]**

ViSiON/2 was beautiful out of the box, insanely configurable and ultimately grew to include the ability to completely emulate any other BBS you could think of via its completely user scriptable workflow and display setup.

ViSiON/2 was my absolute favorite of all the hundreds of bbs programs I played with, and was the only one what I ever worked on.

![V2 FSEd](https://github.com/stlalpha/vision-2-bbs/blob/main/IMAGES/stringeditor.png?raw=true)

## I Must Be Getting Old
I spent an enormous amount of time in this world, it was my primary social outlet in the late 80s and early 90s.

I was the  sysop of multiple bbs's over the years, and I was a dedicated bbs program geek.  I loved the software, configuring it, getting it to do what i wanted to do - as much or more than I did pretty much any other aspect of the BBS world itself.

I was 14 or 15.  Intensely introverted, and interested in technology and the telephone (and tymnet and telenet and arpanet and yes later the internet).  It was super uncool to be this person at that time, but it was my driving passion.

I got to know Crimson Blade at some point in 91 or 92.  I ended up being a ViSiON/2 sysop and provided a ton of feedback - solicited and unsolicited - to Crim as his friends called him.  

We were kids, working together on a software project, servicing users all over the country, in a mostly pre-internet world.  

We were friends, we spent an enormous amount of time on the phone and on party lines when someone had one.  There would a few of us that worked on and helped with ViSiON/2.  And we sort of found our way through it.  No one wrote the software but Crim and later ND, but we helped with features, ideas, bugs, screens, etc.

It was amazing.

## The More You Know

If you want to learn more about that time period and this sub-culture, check out the [BBS Documentary](https://www.youtube.com/watch?v=Dddbe9OuJLU&list=PL7nj3G6Jpv2G6Gp6NvN1kUtQuW8QshBWE).  Its companion website also has an enormous about of information and [source code](http://software.bbsdocumentary.com/IBM/DOS/FORUM/)!
