"use client";

import { usePathname } from "next/navigation";
import { Suspense } from "react";
import Sidebar from "./Sidebar";
import type { Status } from "@/types";

export default function AppShell({
  statuses,
  children,
}: {
  statuses: Status[];
  children: React.ReactNode;
}) {
  const pathname = usePathname();

  if (pathname?.startsWith("/login")) {
    return <>{children}</>;
  }

  return (
    <div className="flex">
      <Suspense fallback={<div className="w-64 shrink-0" />}>
        <Sidebar statuses={statuses} />
      </Suspense>
      <main className="min-h-screen flex-1 bg-slate-50">{children}</main>
    </div>
  );
}
