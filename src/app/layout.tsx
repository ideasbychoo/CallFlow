import type { Metadata, Viewport } from "next";
import "@fontsource/quicksand/400.css";
import "@fontsource/quicksand/500.css";
import "@fontsource/quicksand/600.css";
import "@fontsource/quicksand/700.css";
import "./globals.css";
import AppShell from "@/components/AppShell";
import ServiceWorkerRegister from "@/components/ServiceWorkerRegister";
import { createClient } from "@/lib/supabase/server";
import type { TodayHoliday } from "@/components/HolidayTicker";

export const metadata: Metadata = {
  title: "CallFlow",
  description: "Makerble prospect calling tool",
  manifest: "/manifest.webmanifest",
  appleWebApp: {
    capable: true,
    statusBarStyle: "default",
    title: "CallFlow",
  },
  icons: {
    icon: [
      { url: "/icons/icon-192.png", sizes: "192x192", type: "image/png" },
      { url: "/icons/icon-512.png", sizes: "512x512", type: "image/png" },
    ],
    apple: [{ url: "/apple-touch-icon.png", sizes: "180x180", type: "image/png" }],
  },
};

export const viewport: Viewport = {
  themeColor: "#1e293b",
};

export default async function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const supabase = await createClient();
  const { data: statuses } = await supabase
    .from("statuses")
    .select("id, name, sort_order, counts_as_call_attempt, is_call_or_chase")
    .order("sort_order", { ascending: true });

  const todayIso = new Date().toISOString().slice(0, 10);
  const { data: todaysHolidays } = await supabase
    .from("public_holidays")
    .select("id, name, country:countries(name)")
    .eq("holiday_date", todayIso);

  return (
    <html lang="en">
      <body className="antialiased font-sans">
        <ServiceWorkerRegister />
        <AppShell
          statuses={statuses ?? []}
          todaysHolidays={(todaysHolidays ?? []) as unknown as TodayHoliday[]}
        >
          {children}
        </AppShell>
      </body>
    </html>
  );
}
