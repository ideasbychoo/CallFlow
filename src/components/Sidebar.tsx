"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { usePathname, useRouter, useSearchParams } from "next/navigation";
import {
  Phone,
  Workflow,
  Building2,
  Users,
  Target,
  BarChart3,
  Eye,
  Mail,
  Settings as SettingsIcon,
  LogOut,
  ChevronsLeft,
  ChevronsRight,
  X,
} from "lucide-react";
import { createClient } from "@/lib/supabase/client";
import type { Status } from "@/types";

const COLLAPSE_STORAGE_KEY = "callflow-sidebar-collapsed";

export default function Sidebar({
  statuses,
  mobileOpen = false,
  onCloseMobile,
}: {
  statuses: Status[];
  mobileOpen?: boolean;
  onCloseMobile?: () => void;
}) {
  const pathname = usePathname();
  const searchParams = useSearchParams();
  const router = useRouter();
  const activeStatusId = searchParams.get("status");
  const [collapsed, setCollapsed] = useState(false);

  // Read the persisted preference after mount, so server-rendered markup
  // (which has no access to localStorage) always matches the client's first
  // render and avoids a hydration mismatch. This is a desktop-only
  // preference -- the mobile drawer always shows the full (uncollapsed)
  // layout, since it's a temporary overlay rather than persistent chrome.
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

  function closeMobile() {
    onCloseMobile?.();
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
    { href: "/call-list", label: "Call List", icon: Phone, active: pathname === "/call-list" && !activeStatusId },
    { href: "/pipeline", label: "Pipeline", icon: Workflow, active: pathname === "/pipeline", marginTop: true },
    { href: "/organisations", label: "Organisations", icon: Building2, active: pathname === "/organisations", marginTop: true },
    { href: "/staff", label: "Staff", icon: Users, active: pathname === "/staff" },
    { href: "/research", label: "Research", icon: Target, active: pathname === "/research", marginTop: true },
    { href: "/reporting", label: "Reporting", icon: BarChart3, active: pathname === "/reporting" },
    { href: "/sources", label: "Sources", icon: Eye, active: pathname === "/sources" },
    { href: "/email-templates", label: "Email Templates", icon: Mail, active: pathname === "/email-templates" },
    { href: "/settings", label: "Settings", icon: SettingsIcon, active: pathname === "/settings", marginTop: true },
  ];

  // `collapsed` (icon-only mode) only ever applies at the md+ breakpoint --
  // below md the sidebar is a full-width overlay drawer, so labels always
  // render there via plain (non-`md:`-prefixed) classes, and are only hidden
  // once `md:hidden` kicks in when `collapsed` is true.
  const labelHiddenWhenCollapsed = collapsed ? "md:hidden" : "";
  const justifyWhenCollapsed = collapsed ? "md:justify-center" : "";

  return (
    <>
      {/* Backdrop, mobile only, shown while the drawer is open */}
      {mobileOpen && (
        <div
          className="fixed inset-0 z-40 bg-slate-900/50 md:hidden"
          onClick={closeMobile}
          aria-hidden="true"
        />
      )}

      <aside
        className={`fixed inset-y-0 left-0 z-50 flex w-64 shrink-0 -translate-x-full transform flex-col justify-between overflow-y-auto border-r border-slate-200 bg-white px-5 py-6 transition-transform duration-200 md:static md:z-auto md:translate-x-0 md:transition-[width] md:duration-150 ${
          mobileOpen ? "translate-x-0" : ""
        } ${collapsed ? "md:w-16 md:px-2" : "md:w-64 md:px-5"}`}
      >
        <div className="min-w-0">
          <div className={`mb-2 flex items-center justify-between ${collapsed ? "md:flex-col md:gap-2" : ""}`}>
            <span className={`truncate text-lg font-bold tracking-tight text-slate-900 ${labelHiddenWhenCollapsed}`}>
              CallFlow
            </span>
            {/* Desktop collapse toggle */}
            <button
              onClick={toggleCollapsed}
              title={collapsed ? "Expand menu" : "Collapse menu"}
              aria-label={collapsed ? "Expand menu" : "Collapse menu"}
              className="hidden rounded p-1 text-slate-400 hover:bg-slate-50 hover:text-slate-700 md:block"
            >
              {collapsed ? <ChevronsRight size={18} /> : <ChevronsLeft size={18} />}
            </button>
            {/* Mobile close button */}
            <button
              onClick={closeMobile}
              aria-label="Close menu"
              className="rounded p-1 text-slate-400 hover:bg-slate-50 hover:text-slate-700 md:hidden"
            >
              <X size={20} />
            </button>
          </div>

          {navItems.map((item, index) => (
            <div key={item.href}>
              <Link
                href={item.href}
                onClick={closeMobile}
                title={collapsed ? item.label : undefined}
                className={`flex items-center gap-2 rounded px-1 py-1 text-lg font-semibold ${
                  item.marginTop && index !== 0 ? "mt-6" : ""
                } ${item.active ? "text-slate-900" : "text-slate-700 hover:text-slate-900"} ${justifyWhenCollapsed}`}
              >
                <item.icon size={20} className="shrink-0" />
                <span className={`truncate ${labelHiddenWhenCollapsed}`}>{item.label}</span>
              </Link>

              {item.href === "/call-list" && (
                <ul className={`mt-2 mb-2 space-y-1 ${labelHiddenWhenCollapsed}`}>
                  {sorted.map((status) => (
                    <li key={status.id}>
                      <Link
                        href={`/call-list?status=${status.id}`}
                        onClick={closeMobile}
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
          onClick={() => {
            closeMobile();
            handleLogout();
          }}
          title={collapsed ? "Logout" : undefined}
          className={`flex items-center gap-2 text-left text-lg font-semibold text-slate-700 hover:text-slate-900 ${justifyWhenCollapsed}`}
        >
          <LogOut size={20} className="shrink-0" />
          <span className={labelHiddenWhenCollapsed}>Logout</span>
        </button>
      </aside>
    </>
  );
}
