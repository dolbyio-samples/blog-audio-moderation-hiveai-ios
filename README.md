![Blog Picture](https://dolby.io/wp-content/uploads/2023/04/Dolby.io_Stream-The-World-A-Guide-To-Start-Streaming-Your-Game-1088x450-Purple-BG.png)

# Audio Moderation In Conference Using Hive.ai And The Dolby.io iOS SDK
This repository illustrates how to integrate Hive AI and the Dolby.io iOS SDK to implement conference monitoring during conferences.

# Overview
This repository contains a sample application for the blog post TODO ADD LINK. It allows you to use [Hive Audio Moderation](https://hivemoderation.com/audio-moderation) to capture raw local audio from Dolby.io conference, transcribe raw audio into human readable text, process the full transcription and detects inappropriate content across multiple classes.

# Requirements
If you do not have one already, create an account on [Dolby.io](https://dolby.io/) and retrieve a client access token by connecting to your dashboard and selecting your application then click on API keys in the left menu.

![Client Access Token](images/dolby-io-access-token.png)

Then, create a [Hive](https://thehive.ai) account if you do not have one already and [Request a Demo](https://hivemoderation.com/contact-us?source=hivemoderation-header)

When you have access to to your dashboard, create a project and get your `Hive API Key`.

![Hive API Key](images/hive-api-key.png)

# Getting Started
1. Clone this repository to your local computer and open a project file with Xcode.
2. Make sure your project's **Bundle identifier** and **Team Account** is set for your developement environment.
   - Select the project's target and Signings and Capibilities Tab.
   - Select your team and set the project's bundle ID.
3. Update the Configuration.swift file with Dolby.io Client Access Token and Hive API Key.
4. Select your iOS Device and Run the project.

# Report a Bug 
In the case any bugs occur, report it using Github issues, and we will see to it. 

# Forking
We welcome your interest in trying to experiment with our repos.

# Feedback 
If there are any suggestions or if you would like to deliver any positive notes, feel free to open an issue and let us know!

# Learn More
For a deeper dive, we welcome you to review the following:
 - [Communications API](https://docs.dolby.io/communications-apis/docs)
 - [Getting Started with IOS SDK](https://docs.dolby.io/communications-apis/docs/getting-started-with-ios)
 - [How to Create Your First Audio and Video Call on iOS with Dolby.io using Swift](https://dolby.io/blog/how-to-create-your-first-audio-and-video-call-on-ios-with-dolby-io-using-swift/)
 - [Scaling Your Online Live Events Solution to Host Very Large Audiences](https://dolby.io/blog/scaling-your-online-live-events-solution-to-host-very-large-audiences/)
 - [Recording Audio on iOS with Examples](https://dolby.io/blog/recording-audio-on-ios-with-examples/)

# About Dolby.io
Using decades of Dolby's research in sight and sound technology, Dolby.io provides APIs to integrate real-time streaming, voice & video communications, and file-based media processing into your applications. [Sign up for a free account](https://dashboard.dolby.io/signup/) to get started building the next generation of immersive, interactive, and social apps.

<div align="center">
  <a href="https://dolby.io/" target="_blank"><img src="https://img.shields.io/badge/Dolby.io-0A0A0A?style=for-the-badge&logo=dolby&logoColor=white"/></a>
&nbsp; &nbsp; &nbsp;
  <a href="https://docs.dolby.io/" target="_blank"><img src="https://img.shields.io/badge/Dolby.io-Docs-0A0A0A?style=for-the-badge&logoColor=white"/></a>
&nbsp; &nbsp; &nbsp;
  <a href="https://dolby.io/blog/category/developer/" target="_blank"><img src="https://img.shields.io/badge/Dolby.io-Blog-0A0A0A?style=for-the-badge&logoColor=white"/></a>
</div>

<div align="center">
&nbsp; &nbsp; &nbsp;
  <a href="https://youtube.com/@dolbyio" target="_blank"><img src="https://img.shields.io/badge/YouTube-red?style=flat-square&logo=youtube&logoColor=white" alt="Dolby.io on YouTube"/></a>
&nbsp; &nbsp; &nbsp; 
  <a href="https://twitter.com/dolbyio" target="_blank"><img src="https://img.shields.io/badge/Twitter-blue?style=flat-square&logo=twitter&logoColor=white" alt="Dolby.io on Twitter"/></a>
&nbsp; &nbsp; &nbsp;
  <a href="https://www.linkedin.com/company/dolbyio/" target="_blank"><img src="https://img.shields.io/badge/LinkedIn-0077B5?style=flat-square&logo=linkedin&logoColor=white" alt="Dolby.io on LinkedIn"/></a>
</div>
