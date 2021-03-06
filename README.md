# The guest service

Securely exposes new features in production with [SSH remote port forwarding](https://www.ssh.com/ssh/tunneling/example) and [Docker](https://www.docker.com/). 

## Welcome, Guest!

The SSH server on my Raspberry Pi is now open to public. Run
```
docker run -v $HOME:/umf -it docker.io/amissine/ali_guest:1.0.0
```
to get real-time market feed (trades, orderbooks) from 4 crypto exchanges. In your browser, go to [Play with Docker](https://labs.play-with-docker.com/), Login as docker, Start, ADD NEW INSTANCE, copy and paste the above into the command line. Now SSH to this instance from your own box and watch the feed coming your way in real time: `tail -f feed`.

## Overview

A piece of software is a living thing. Its habitat is the community of users. When it goes to production, the public feedback can either kill it, or make it stronger - provided it is  exposed to the public properly. Here I am talking about early, demo-like, exposure of something new in my software.

For example, presently [my piece of software](https://docs.google.com/document/d/11oG00Nvn6vcFC2AemFmSkZNp0trEFrUHxL0IrkGR45c/ "the ALI project") collects market feed from multiple crypto exchanges (Bitfinex, Coinbase, Kraken, SDEX) for multiple assets (BTC, CNY, EUR, ETH, XLM, XRP, XXA), and then saves and archives the feed uniformly. I want to expose the feed to the public as soon as it reaches, in my opinion, production quality - meaning, it does not break on an error from the source and keeps accumulating, quietly. It would be nice (and cost-effective, too) to demo the feed with SSH, while keeping my resources from being compromised.

As the feed is being accumulated, it can be transfered to an SSH client. And how do I prevent the client from doing anything else on [my tiny server](https://drive.google.com/file/d/1tiVi1AVFkxgE-5RaiBIqzkmofzAcwlb9/view?usp=sharing "Raspberry Pi 4B")? The SSH remote port forwarding comes handy here. The client logs in as `guest` (and `guest` is a minimally-privileged account on my server), passing to the server the port number to use for remote port forwarding. The `guest` account on the server takes this port (for example, `12345`) and connects back to the client like this:

```
ssh -p 12345 root@localhost './accept_transfer.sh'
```

And then this second connection is used to transfer the feed to the client.

But you would not want me to access your box as `root`, would you? And I am not doing that. Instead, it is the Docker image on your client box my server is communicating with for the duration of the demo. You run the image in the Docker container as follows:

```
docker run -v $HOME:/umf -it docker.io/amissine/ali_guest:1.0.0
```

The image:
- gets pulled from DockerHub (unless pulled already);
- runs in a container for the duration of the demo:
  - connects and logs in to my server as `guest`;
  - passes to my server the port number to use for remote port forwarding;
  - accepts the connection from my server;
  - on that second connection, the image:
    - accepts the historical and the real-time parts of the current market feed;
    - saves the `feed` for subsequent analysis in your $HOME directory.
      > And your home directory is outside the image container :)

Not bad for a one-liner, is it?

## Discussion

In this setup, the server has full control over the resources it exposes to the client, and so does the client with relation to the server. This can be used by independent parties to securely collaborate during the R&D phase on a decentralised enterprise. For example, you can use my feed to develop and test your own trading strategy.
