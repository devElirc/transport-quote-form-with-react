import { describe, expect, it } from "vitest";
import fs from "node:fs";

const appHtmlPath = "/app/index.html";

function readHtml() {
  if (!fs.existsSync(appHtmlPath)) {
    throw new Error(`Missing ${appHtmlPath}`);
  }

  return fs.readFileSync(appHtmlPath, "utf8");
}

describe("transport quote form markup contract", () => {
  it("includes the expected page chrome and step labels", () => {
    const html = readHtml();

    expect(html).toContain("<title>Transport Quote Form</title>");
    expect(html).toContain("Transport car pickup and destination.");
    expect(html).toContain("Destination");
    expect(html).toContain("Vehicle");
    expect(html).toContain("VEHICLE DETAILS");
    expect(html).toContain("SAVE Calculate Cost");
  });

  it("includes accessible labels and the dependent vehicle model control", () => {
    const html = readHtml();

    expect(html).toMatch(/aria-label="Pickup"/);
    expect(html).toMatch(/aria-label="Delivery"/);
    expect(html).toMatch(/aria-label="Vehicle Year"/);
    expect(html).toMatch(/aria-label="Vehicle Make"/);
    expect(html).toMatch(/aria-label="Vehicle Model"/);
    expect(html).toMatch(/id="vehicle-model"[\s\S]*disabled|disabled[\s\S]*id="vehicle-model"/);
  });

  it("includes validation copy and the year datalist hook", () => {
    const html = readHtml();

    expect(html).toContain("Please enter both pickup and delivery locations.");
    expect(html).toContain('list="vehicle-year-options"');
  });

  it("includes mocked Toyota models and dependent model wiring", () => {
    const html = readHtml();

    expect(html).toContain("Toyota");
    expect(html).toContain("Camry");
    expect(html).toContain("Corolla");
    expect(html).toContain("RAV4");
    expect(html).toContain("Tacoma");
    expect(html).toContain("populateModels");
    expect(html).toContain("for (let year = currentYear; year >= 1980; year -= 1)");
  });
});
