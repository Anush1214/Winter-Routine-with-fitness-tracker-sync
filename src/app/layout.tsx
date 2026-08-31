import type { Metadata, Viewport } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "WINTER ARC 2026 // 4-Month Personal Productivity Protocol",
  description: "Strict 4-month daily transformation protocol (Sept 1 - Dec 31). Dynamic routines, smartwatch health auto-sync, and native mobile push alerts.",
  manifest: "/manifest.json",
  appleWebApp: {
    capable: true,
    statusBarStyle: "black-translucent",
    title: "Winter Arc",
  },
  icons: {
    icon: "/icons/icon-192.png",
    apple: "/icons/icon-512.png",
  },
};

export const viewport: Viewport = {
  themeColor: "#060913",
  width: "device-width",
  initialScale: 1,
  maximumScale: 1,
  userScalable: false,
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en" className="dark">
      <head>
        <link rel="preconnect" href="https://fonts.googleapis.com" />
        <link rel="preconnect" href="https://fonts.gstatic.com" crossOrigin="anonymous" />
        <link
          href="https://fonts.googleapis.com/css2?family=Outfit:wght@400;500;600;700;800;900&family=JetBrains+Mono:wght@400;500;600;700&display=swap"
          rel="stylesheet"
        />
      </head>
      <body className="antialiased selection:bg-cyan-500/30 selection:text-cyan-200">
        <div className="relative min-h-screen flex flex-col justify-between">
          <main className="flex-1 max-w-5xl mx-auto w-full px-3 sm:px-6 py-4 sm:py-8">
            {children}
          </main>
        </div>
      </body>
    </html>
  );
}
