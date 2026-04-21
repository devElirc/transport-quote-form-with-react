import { describe, expect, it } from "vitest";
import fs from "node:fs";
import path from "node:path";

const APP_DIR = "/app";

function walkFiles(dir: string): string[] {
  if (!fs.existsSync(dir)) {
    return [];
  }

  return fs.readdirSync(dir, { withFileTypes: true }).flatMap((entry) => {
    const fullPath = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      if (["node_modules", ".git", "dist", "build"].includes(entry.name)) {
        return [];
      }
      return walkFiles(fullPath);
    }
    return [fullPath];
  });
}

function readTextFiles(dir: string): string {
  const textExtensions = new Set([
    ".html",
    ".js",
    ".jsx",
    ".ts",
    ".tsx",
    ".css",
    ".json",
  ]);

  return walkFiles(dir)
    .filter((file) => textExtensions.has(path.extname(file).toLowerCase()))
    .map((file) => fs.readFileSync(file, "utf8"))
    .join("\n");
}

describe("transport quote form source", () => {
  it("includes the required user-facing copy for all three steps", () => {
    const source = readTextFiles(APP_DIR);

    expect(source).toContain("Destination");
    expect(source).toContain("Vehicle");
    expect(source).toContain("Date");
    expect(source).toContain("Transport car pickup and destination.");
    expect(source).toContain("VEHICLE DETAILS");
    expect(source).toContain("Vehicle Year");
    expect(source).toContain("Vehicle Make");
    expect(source).toContain("Vehicle Model");
    expect(source).toContain("SAVE VEHICLE");
    expect(source).toContain("Full Name");
    expect(source).toContain("Shipping Date");
    expect(source).toContain("Email");
    expect(source).toContain("Phone");
    expect(source).toContain("Calculate Cost");
  });

  it("shows evidence that the page was built with React", () => {
    const source = readTextFiles(APP_DIR).toLowerCase();

    expect(source.length).toBeGreaterThan(0);
    expect(source).toMatch(/react|react-dom|createRoot|from\s+["']react["']/);
  });
});
