"use client";

import { useEffect } from "react";

export default function Modal({
  onClose,
  children,
}: {
  onClose: () => void;
  children: React.ReactNode;
}) {
  useEffect(() => {
    function handleKey(e: KeyboardEvent) {
      if (e.key === "Escape") onClose();
    }
    document.addEventListener("keydown", handleKey);
    // Prevent the page behind the modal from scrolling while it's open.
    const previousOverflow = document.body.style.overflow;
    document.body.style.overflow = "hidden";
    return () => {
      document.removeEventListener("keydown", handleKey);
      document.body.style.overflow = previousOverflow;
    };
  }, [onClose]);

  return (
    <div
      className="fixed inset-0 z-50 flex items-start justify-center overflow-y-auto bg-slate-900/60 p-4 pt-12 sm:pt-16"
      onMouseDown={(e) => {
        if (e.target === e.currentTarget) onClose();
      }}
    >
      <div className="relative w-[92vw]">
        <button
          onClick={onClose}
          aria-label="Close"
          className="absolute -top-10 right-0 text-2xl leading-none text-white/80 hover:text-white sm:top-1 sm:-right-10"
        >
          ✕
        </button>
        <div className="max-h-[85vh] overflow-y-auto rounded-xl bg-white shadow-2xl">
          {children}
        </div>
      </div>
    </div>
  );
}
