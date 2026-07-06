import type { Metadata } from "next";
import "./globals.css";
import AppShell from "@/components/AppShell";
import { createClient } from "@/lib/supabase/server";

export const metadata: Metadata = {
  title: "CallFlow",
  description: "Makerble prospect calling tool",
};

export default async function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const supabase = await createClient();
  const { data: statuses } = await supabase
    .from("statuses")
    .select("id, name, sort_order")
    .order("sort_order", { ascending: true });

  return (
    <html lang="en">
      <body className="antialiased">
        <AppShell statuses={statuses ?? []}>{children}</AppShell>
      </body>
    </html>
  );
}
