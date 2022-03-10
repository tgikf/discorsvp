# DiscoRSVP

> The name DiscoRSVP is a combination of Discord, a popular VoIP tool among gamers, and `RSVP`, an initialism derived from the French phrase Répondez s'il vous plaît, literally meaning "Respond, If-You-Please", or just "Please Respond", to require confirmation of an invitation.

## What even is this?

Do you enjoy ganging up with your friends in Discord channels when playing video games? \
Do you have terrible friends that seemingly accept your invite to play but don't actually show up? \
Are you fed up with getting baited? \
Then **DiscoRSVP** is for you!

DiscoRSVP is a pet project that allows you to announce gaming sessions and tie them to a specific Discord channel. The app will track attendance on the selected channel and notify your Squad when everybody is there.

## DiscoRSVP app

This repository contains the DiscoRSVP mobile app.
It's a Flutter project implemented in Dart that consists of:

- An authentication layer to authenticate Discord users via [Auth0](https://auth0.com/)
- A `socket.io` based websocket to communicate with [`discorsvp-service`](https://github.com/tgikf/discorsvp-service/)
