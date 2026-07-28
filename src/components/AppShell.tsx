"use client";

import { usePathname } from "next/navigation";
import { Suspense, useState } from "react";
import { Menu } from "lucide-react";
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
  const [mobileOpen, setMobileOpen] = useState(false);

  if (pathname?.startsWith("/login")) {
    return <>{children}</>;
  }

  return (
    <div className="flex h-screen flex-col overflow-hidden md:flex-row">
      {/* Mobile-only top bar: hamburger to open the drawer + platform name */}
      <div className="flex shrink-0 items-center justify-between border-b border-slate-200 bg-white px-4 py-3 md:hidden">
        <button
          onClick={() => setMobileOpen(true)}
          aria-label="Open menu"
          className="text-slate-600 hover:text-slate-900"
        >
          <Menu size={24} />
        </button>
        <span className="text-lg font-bold tracking-tight text-slate-900">CallFlow</span>
        <span className="w-6" aria-hidden="true" />
      </div>

      <div className="flex min-h-0 min-w-0 flex-1">
        <Suspense fallback={<div className="w-64 shrink-0 max-md:hidden" />}>
          <Sidebar
            statuses={statuses}
            mobileOpen={mobileOpen}
            onCloseMobile={() => setMobileOpen(false)}
          />
        </Suspense>
        <main id="main-scroll" className="h-full min-w-0 flex-1 overflow-y-auto bg-slate-50">
          {children}
        </main>
      </div>
    </div>
  );
}
