# mobiledashboard

A high-performance, mobile-optimized Agent Platform dashboard built with Tailwind CSS and Phosphor Icons.

## Features
- **Mobile-First Design**: Optimized for touch interactions and small screens.
- **Agent Composer**: Quick access to AI agent interactions.
- **Automations**: Manage and deploy workflow automations.
- **History & Diffs**: Review past agent activities with detailed code diffs.
- **CI/CD Ready**: Configured for seamless deployment via Cloudflare Pages.

## Deployment to Cloudflare Pages

This repository is designed to work out-of-the-box with Cloudflare Pages.

1.  Log in to the [Cloudflare Dashboard](https://dash.cloudflare.com/).
2.  Navigate to **Workers & Pages** > **Create application** > **Pages** > **Connect to Git**.
3.  Select the `mobiledashboard` repository.
4.  **Build Settings**:
    - **Framework preset**: None (Static site)
    - **Build command**: (Leave empty)
    - **Build output directory**: `/` (Root)
5.  Click **Save and Deploy**.

Cloudflare will automatically deploy every push to the `main` branch.

## Tech Stack
- **HTML5**
- **Tailwind CSS** (via CDN for rapid prototyping)
- **Phosphor Icons**
- **Cloudflare Pages** (CI/CD)
