import type { Config } from "tailwindcss";

const config: Config = {
  content: [
    "./pages/**/*.{js,ts,jsx,tsx,mdx}",
    "./components/**/*.{js,ts,jsx,tsx,mdx}",
    "./app/**/*.{js,ts,jsx,tsx,mdx}",
  ],
  theme: {
    extend: {
      colors: {
        background: "#050810",
        surface: "#0c1120",
        surface2: "#111827",
        border: "rgba(255,255,255,0.07)",
        border2: "rgba(255,255,255,0.13)",
        accent: "#00e5ff",
        accent2: "#7c3aed",
        danger: "#ff4d6d",
        success: "#22d3a5",
        warning: "#fbbf24",
        text: "#f0f4ff",
        muted: "#8892a4",
      },
      fontFamily: {
        display: ["var(--font-syne)", "sans-serif"],
        body: ["var(--font-dm-sans)", "sans-serif"],
      },
      animation: {
        "fade-up": "fadeUp 0.6s ease forwards",
        pulse: "pulse 2s ease-in-out infinite",
        spin: "spin 0.7s linear infinite",
        tick: "tick 35s linear infinite",
        glow: "glow 2s ease-in-out infinite",
      },
      keyframes: {
        fadeUp: {
          from: { opacity: "0", transform: "translateY(18px)" },
          to: { opacity: "1", transform: "translateY(0)" },
        },
        pulse: {
          "0%, 100%": { opacity: "1", transform: "scale(1)" },
          "50%": { opacity: "0.4", transform: "scale(1.5)" },
        },
        spin: {
          to: { transform: "rotate(360deg)" },
        },
        tick: {
          from: { transform: "translateX(0)" },
          to: { transform: "translateX(-50%)" },
        },
        glow: {
          "0%, 100%": { opacity: "0.5" },
          "50%": { opacity: "1" },
        },
      },
    },
  },
  plugins: [],
};

export default config;
