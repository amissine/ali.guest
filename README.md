# The guest service

Securely demoes new features in production with [SSH remote port forwarding](https://www.ssh.com/ssh/tunneling/example) and [Docker](https://www.docker.com/) images. 

## Overview

A piece of software is a living thing. Its habitat is the community of users. When it goes to production, the public feedback can either kill it, or make it stronger - provided it is  exposed to the public nicely. Here I am talking about early, demo-like, exposure of something new.

For example, [my piece of software](https://docs.google.com/document/d/11oG00Nvn6vcFC2AemFmSkZNp0trEFrUHxL0IrkGR45c/ "the ALI project") collects market feed from multiple crypto exchanges (Bitfinex, Coinbase, Kraken, SDEX) for multiple assets (BTC, CNY, EUR, ETH, XLM, XRP, XXA), and then saves/archives the feed uniformly. I want to expose the feed to the public as soon as it reaches, in my opinion, production quality - meaning, it does not break on an error from the source and keeps accumulating, quietly. It would be nice (and cost-effective, too) to demo the feed with SSH, while keeping my resources from being compromised.

As the feed is being accumulated, it can be transfered to an SSH client. And how do I prevent the client from doing anything else on my server? The SSH remote port forwarding comes handy here. The client logs in as `guest` (and `guest` is an ultimately non-privileged account on my server), passing to the server the port number to use for remote port forwarding. The `root` account on the server takes this port (for example, `12345`) and connects back to the client as follows:

```
ssh -p 12345 root@localhost './accept_transfer.sh'
```

And then this second connection is used by `root` on the server to transfer the feed to the client. The `guest` account requests the transfer, the `root` account performs it. No worries on my side.

But you would not want me to access your box as `root`, would you? And I am not doing that. Instead, it is the Docker image on your box my server is communicating with for the duration of the demo. You run the image as follows:

```
sudo docker run -it docker.io/amissine/guest:1.0.0
```

The image:
- gets pulled from DockerHub (unless pulled already);
- runs in a container for the duration of the demo:
  - logs in to my server as `guest`;
  - passes to my server the port number to use for remote port forwarding;
  - accepts the connection from my server;
  - runs `./accept_transfer.sh` inside the image container:
    - accepts the historical and the real-time parts of the current market feed;
    - outputs the feed to your terminal;
    - saves the feed for subsequent analysis in your $HOME/amissine/feed directory.
      > Please note that this directory is outside the image container.

Not bad for a one-liner, is it? Try it out!
