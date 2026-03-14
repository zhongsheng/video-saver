# AGENTS.md

## Project Overview
This project helps users download videos that are shared through WeChat.

- User adds the WeChat bot as a friend.
- User forwards a video to the bot.
- Bot sends a mini-program link/card to the user.
- User opens the mini-program and downloads the video.
- After download is completed, backend deletes buffered video files to save server storage.

## Tech Stack
- Backend: Ruby on Rails + SQLite
- Frontend: WeChat Mini Program

## Product Notes (中英说明)
- 本项目用于处理“用户通过微信转发视频给机器人后下载视频”的场景。
- 后端使用 Rails + SQLite 做用户管理、视频下载与转存。
- 用户添加微信 bot 好友后，转发视频给 bot。
- bot 下发小程序给用户，用户打开小程序下载视频。
- 用户下载完成后，后端需要删除缓存视频，节省服务器空间。

## Engineering Principles
1. Keep dependencies minimal for both frontend and backend.
2. Prefer built-in framework/library capabilities over adding third-party packages.
3. Keep video lifecycle explicit: receive -> process/store -> deliver -> cleanup.
4. Prioritize reliability and storage efficiency.

## Dependency Policy
- 无论前端后端，尽可能不添加外部依赖。
- If a new dependency is unavoidable, document why it is necessary and evaluate lighter alternatives first.
