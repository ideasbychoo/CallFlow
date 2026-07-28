"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { usePathname, useRouter, useSearchParams } from "next/navigation";
import {
  List,
  Workflow,
  Building2,
  Users,
  BarChart3,
  Radar,
  Mail,
  Settings as SettingsIcon,
  LogOut,
  ChevronsLeft,
  ChevronsRight,
} from "lucide-react";
import { createClient } from "@/lib/supabase/client";
import type { Status } from "@/types";

const COLLAPSE_STORAGE_KEY = "callflow-sidebar-collapsed";

export default function Sidebar({ statuses }: { statuses: Status[] }) {
  const pathname = usePathname();
  const searchParams = useSearchParams();
  const router = useRouter();
  const activeStatusId = searchParams.get("status");
  const [collapsed, setCollapsed] = useState(false);

  // Read the persisted preference after mount, so server-rendered markup
  // (which has no access to localStorage) always matches the client's first
  // render and avoids a hydration mismatch.
  useEffect(() => {
    const stored = window.localStorage.getItem(COLLAPSE_STORAGE_KEY);
    if (stored === "true") setCollapsed(true);
  }, []);

  function toggleCollapsed() {
    setCollapsed((prev) => {
      const next = !prev;
      window.localStorage.setItem(COLLAPSE_STORAGE_KEY, String(next));
      return next;
    });
  }

  async function handleLogout() {
    const supabase = createClient();
    await supabase.auth.signOut();
    router.push("/login");
    router.refresh();
  }

  const sorted = [...statuses].sort((a, b) => a.sort_order - b.sort_order);

  const navItems: {
    href: string;
    label: string;
    icon: React.ElementType;
    active: boolean;
    marginTop?: boolean;
  }[] = [
    { href: "/call-list", label: "Call List", icon: List, active: pathname === "/call-list" && !activeStatusId },
    { href: "/pipeline", label: "Pipeline", icon: Workflow, active: pathname === "/pipeline", marginTop: true },
    { href: "/organisations", label: "Organisations", icon: Building2, active: pathname === "/organisations", marginTop: true },
    { href: "/staff", label: "Staff", icon: Users, active: pathname === "/staff" },
    { href: "/reporting", label: "Reporting", icon: BarChart3, active: pathname === "/reporting", marginTop: true },
    { href: "/sources", label: "Sources", icon: Radar, active: pathname === "/sources" },
    { href: "/email-templates", label: "Email Templates", icon: Mail, active: pathname === "/email-templates" },
    { href: "/settings", label: "Settings", icon: SettingsIcon, active: pathname === "/settings", marginTop: true },
  ];

  return (
    <aside
      className={`flex h-screen shrink-0 flex-col justify-between overflow-y-auto border-r border-slate-200 bg-white py-6 transition-[width] duration-150 ${
        collapsed ? "w-16 px-2" : "w-64 px-5"
      }`}
    >
      <div className="min-w-0">
        <div className={`mb-2 flex items-center ${collapsed ? "justify-center" : "justify-end"}`}>
          <button
            onClick={toggleCollapsed}
            title={collapsed ? "Expand menu" : "Collapse menu"}
            aria-label={collapsed ? "Expand menu" : "Collapse menu"}
            className="rounded p-1 text-slate-400 hover:bg-slate-50 hover:text-slate-700"
          >
            {collapsed ? <ChevronsRight size={18} /> : <ChevronsLeft size={18} />}
          </button>
        </div>

        {navItems.map((item, index) => (
          <div key={item.href}>
            <Link
              href={item.href}
              title={collapsed ? item.label : undefined}
              className={`flex items-center gap-2 rounded px-1 py-1 text-lg font-semibold ${
                item.marginTop && index !== 0 ? "mt-6" : ""
              } ${item.active ? "text-slate-900" : "text-slate-700 hover:text-slate-900"} ${
                collapsed ? "justify-center" : ""
              }`}
            >
              <item.icon size={20} className="shrink-0" />
              {!collapsed && <span className="truncate">{item.label}</span>}
            </Link>

            {item.href === "/call-list" && !collapsed && (
              <ul className="mt-2 mb-2 space-y-1">
                {sorted.map((status) => (
                  <li key={status.id}>
                    <Link
                      href={`/call-list?status=${status.id}`}
                      className={`block rounded px-2 py-1 text-sm ${
                        activeStatusId === status.id
                          ? "bg-slate-100 font-medium text-slate-900"
                          : "text-slate-600 hover:bg-slate-50"
                      }`}
                    >
                      {status.name}
                    </Link>
                  </li>
                ))}
              </ul>
            )}
          </div>
        ))}
      </div>

      <button
        onClick={handleLogout}
        title={collapsed ? "Logout" : undefined}
        className={`flex items-center gap-2 text-left text-lg font-semibold text-slate-700 hover:text-slate-900 ${
          collapsed ? "justify-center" : ""
        }`}
      >
        <LogOut size={20} className="shrink-0" />
        {!collapsed && <span>Logout</span>}
      </button>
    </aside>
  );
}
