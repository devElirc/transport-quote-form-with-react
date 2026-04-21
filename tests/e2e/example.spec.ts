import { test, expect, Page } from "@playwright/test";

async function goToVehicleStep(page: Page) {
  await page.goto("/");
  await expect(
    page.getByText("Transport car pickup and destination.", { exact: true }),
  ).toBeVisible();

  await page.getByLabel(/pickup/i).fill("Los Angeles");
  await page.getByLabel(/delivery/i).fill("Houston");
  await expect(
    page.getByRole("button", { name: /vehicle details/i }),
  ).toBeEnabled();
  await page.getByRole("button", { name: /vehicle details/i }).click();

  await expect(
    page.getByRole("combobox", { name: /vehicle year/i }),
  ).toBeVisible();
}

test("blocks direct access to future steps until the current step is completed", async ({
  page,
}) => {
  await page.goto("/");
  const vehicleStep = page.getByRole("button", { name: /^Vehicle$/i });
  const dateStep = page.getByRole("button", { name: /^Date$/i });

  await expect(
    page.getByText("Transport car pickup and destination.", { exact: true }),
  ).toBeVisible();
  await expect(vehicleStep).toBeDisabled();
  await expect(dateStep).toBeDisabled();

  await vehicleStep.click({ force: true });
  await expect(page.getByLabel(/vehicle make/i)).toHaveCount(0);
  await expect(
    page.getByText("Transport car pickup and destination.", { exact: true }),
  ).toBeVisible();

  await dateStep.click({ force: true });
  await expect(page.getByLabel(/full name/i)).toHaveCount(0);
  await expect(
    page.getByText("Transport car pickup and destination.", { exact: true }),
  ).toBeVisible();
});

test("swaps pickup and delivery values before moving to vehicle details", async ({
  page,
}) => {
  await page.goto("/");

  const pickup = page.getByLabel(/pickup/i);
  const delivery = page.getByLabel(/delivery/i);
  const swapButton = page.getByRole("button", {
    name: /swap|switch|exchange/i,
  });
  const nextButton = page.getByRole("button", { name: /vehicle details/i });

  await expect(nextButton).toBeDisabled();
  await pickup.fill("Los Angeles");
  await delivery.fill("Houston");
  await swapButton.click();

  await expect(pickup).toHaveValue("Houston");
  await expect(delivery).toHaveValue("Los Angeles");
  await expect(nextButton).toBeEnabled();
});

test("shows the vehicle step with year choices from the current year down to 1980", async ({
  page,
}) => {
  await goToVehicleStep(page);

  const yearControl = page.getByRole("combobox", { name: /vehicle year/i });
  const currentYear = String(new Date().getFullYear());

  await expect(yearControl).toBeVisible();
  await expect(yearControl.locator(`option[value="${currentYear}"]`)).toHaveCount(1);
  await expect(yearControl.locator('option[value="1980"]')).toHaveCount(1);
});

test("keeps the model field disabled until a make is chosen, then enables it", async ({
  page,
}) => {
  await goToVehicleStep(page);

  const make = page.getByLabel(/vehicle make/i);
  const model = page.getByLabel(/vehicle model/i);
  const makeOptions = make.locator("option");
  const optionCount = await makeOptions.count();
  let chosenMake: string | null = null;

  await expect(model).toBeDisabled();

  for (let index = 1; index < optionCount; index += 1) {
    const value = await makeOptions.nth(index).getAttribute("value");
    const label = (await makeOptions.nth(index).textContent())?.trim() ?? "";
    if ((value && value.trim()) || label) {
      chosenMake = value && value.trim() ? value : label;
      if (chosenMake) {
        break;
      }
    }
  }

  expect(chosenMake).toBeTruthy();
  await make.selectOption(chosenMake!);

  await expect(model).toBeEnabled();
  expect(await model.locator("option").count()).toBeGreaterThan(1);
});

test("progresses to the final step and shows contact details plus shipping date", async ({
  page,
}) => {
  await goToVehicleStep(page);

  const year = page.getByRole("combobox", { name: /vehicle year/i });
  const make = page.getByLabel(/vehicle make/i);
  const model = page.getByLabel(/vehicle model/i);

  await year.selectOption(String(new Date().getFullYear()));

  const selectableMake = await make.locator("option[value]").evaluateAll((options) =>
    options
      .map((option) => option.getAttribute("value") ?? "")
      .find((value) => value.trim().length > 0) ?? "",
  );
  if (selectableMake) {
    await make.selectOption(selectableMake);
  }

  const selectableModel = await model.locator("option[value]").evaluateAll((options) =>
    options
      .map((option) => option.getAttribute("value") ?? "")
      .find((value) => value.trim().length > 0) ?? "",
  );
  if (selectableModel) {
    await model.selectOption(selectableModel);
  }

  await expect(page.getByRole("button", { name: /save vehicle/i })).toBeEnabled();
  await page.getByRole("button", { name: /save vehicle/i }).click();

  await expect(page.getByLabel(/full name/i)).toBeVisible();
  await expect(page.getByLabel(/shipping date/i)).toBeVisible();
  await expect(page.getByLabel(/email/i)).toBeVisible();
  await expect(page.getByLabel(/phone/i)).toBeVisible();
  await expect(page.getByLabel(/shipping date/i)).toHaveAttribute("type", "date");
  await expect(
    page.getByRole("button", { name: /calculate cost/i }),
  ).toBeVisible();
});
