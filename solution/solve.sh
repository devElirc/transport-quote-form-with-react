#!/usr/bin/env bash
set -euo pipefail

mkdir -p /app/src

cat > /app/package.json <<'EOF'
{
  "name": "transport-quote-form",
  "private": true,
  "version": "0.0.0",
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "preview": "vite preview"
  },
  "dependencies": {
    "react": "^18.3.1",
    "react-dom": "^18.3.1"
  },
  "devDependencies": {
    "@vitejs/plugin-react": "^4.3.4",
    "vite": "^5.4.10"
  }
}
EOF

cat > /app/vite.config.js <<'EOF'
import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";

export default defineConfig({
  plugins: [react()],
});
EOF

cat > /app/index.html <<'EOF'
<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Transport Quote Form</title>
    <script type="module" src="/src/main.jsx"></script>
  </head>
  <body>
    <div id="root"></div>
  </body>
</html>
EOF

cat > /app/src/main.jsx <<'EOF'
import React from "react";
import ReactDOM from "react-dom/client";
import App from "./App";
import "./styles.css";

ReactDOM.createRoot(document.getElementById("root")).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>,
);
EOF

cat > /app/src/App.jsx <<'EOF'
import { useMemo, useState } from "react";

const currentYear = new Date().getFullYear();
const years = Array.from({ length: currentYear - 1979 }, (_, index) =>
  String(currentYear - index),
);

const vehicleData = {
  Toyota: ["Camry", "Corolla", "RAV4", "Tacoma"],
  Honda: ["Accord", "Civic", "CR-V", "Pilot"],
  Ford: ["F-150", "Escape", "Explorer", "Mustang"],
  Chevrolet: ["Silverado", "Equinox", "Tahoe", "Malibu"],
};

const stepMeta = [
  { id: 1, label: "Destination" },
  { id: 2, label: "Vehicle" },
  { id: 3, label: "Date" },
];

function StepPill({ id, label, currentStep, maxUnlockedStep, onSelect }) {
  const isCurrent = currentStep === id;
  const isLocked = id > maxUnlockedStep;

  return (
    <button
      type="button"
      className={`step-pill ${isCurrent ? "step-pill--current" : ""} ${
        isLocked ? "step-pill--locked" : "step-pill--available"
      }`}
      aria-current={isCurrent ? "step" : undefined}
      aria-disabled={isLocked}
      disabled={isLocked}
      onClick={() => onSelect(id)}
    >
      <span className="step-pill__number">{id}</span>
      <span className="step-pill__label">{label}</span>
    </button>
  );
}

function StepOne({ pickup, delivery, setPickup, setDelivery, onContinue }) {
  const canContinue = useMemo(
    () => pickup.trim().length > 0 && delivery.trim().length > 0,
    [pickup, delivery],
  );

  const swapLocations = () => {
    setPickup(delivery);
    setDelivery(pickup);
  };

  return (
    <section className="quote-card" aria-labelledby="transport-step-title">
      <div className="quote-card__header">
        <p className="quote-card__eyebrow">Step 1</p>
        <h1 id="transport-step-title">Transport car pickup and destination.</h1>
      </div>

      <div className="location-box">
        <label className="field" htmlFor="pickup">
          <span className="field__label">Pickup</span>
          <div className="field__control">
            <span className="field__icon" aria-hidden="true">
              🔎
            </span>
            <input
              id="pickup"
              name="pickup"
              type="text"
              placeholder="City or ZIP code"
              value={pickup}
              onChange={(event) => setPickup(event.target.value)}
            />
          </div>
        </label>

        <button
          type="button"
          className="swap-button"
          onClick={swapLocations}
          aria-label="Swap pickup and delivery"
        >
          ⇅
        </button>

        <label className="field" htmlFor="delivery">
          <span className="field__label">Delivery</span>
          <div className="field__control">
            <span className="field__icon" aria-hidden="true">
              ⚑
            </span>
            <input
              id="delivery"
              name="delivery"
              type="text"
              placeholder="City or ZIP code"
              value={delivery}
              onChange={(event) => setDelivery(event.target.value)}
            />
          </div>
        </label>
      </div>

      <button
        type="button"
        className="primary-button"
        disabled={!canContinue}
        onClick={onContinue}
      >
        VEHICLE DETAILS
      </button>
    </section>
  );
}

function StepTwo({
  vehicleYear,
  setVehicleYear,
  vehicleMake,
  setVehicleMake,
  vehicleModel,
  setVehicleModel,
  onContinue,
}) {
  const modelOptions = vehicleMake ? vehicleData[vehicleMake] ?? [] : [];
  const canContinue =
    vehicleYear.trim().length > 0 &&
    vehicleMake.trim().length > 0 &&
    vehicleModel.trim().length > 0;

  const handleMakeChange = (event) => {
    const nextMake = event.target.value;
    setVehicleMake(nextMake);
    setVehicleModel("");
  };

  return (
    <section className="quote-card" aria-labelledby="vehicle-step-title">
      <div className="quote-card__header">
        <p className="quote-card__eyebrow">Step 2</p>
        <h1 id="vehicle-step-title">Vehicle details</h1>
      </div>

      <div className="form-grid">
        <label className="field" htmlFor="vehicle-year">
          <span className="field__label">Vehicle Year</span>
          <input
            id="vehicle-year"
            name="vehicle-year"
            list="vehicle-year-options"
            className="field__input"
            placeholder="Select or type year"
            value={vehicleYear}
            onChange={(event) => setVehicleYear(event.target.value)}
          />
          <datalist id="vehicle-year-options">
            {years.map((year) => (
              <option key={year} value={year}>
                {year}
              </option>
            ))}
          </datalist>
          <select
            aria-label="Vehicle Year"
            className="field__select"
            value={vehicleYear}
            onChange={(event) => setVehicleYear(event.target.value)}
          >
            <option value="">Select year</option>
            {years.map((year) => (
              <option key={year} value={year}>
                {year}
              </option>
            ))}
          </select>
        </label>

        <label className="field" htmlFor="vehicle-make">
          <span className="field__label">Vehicle Make</span>
          <select
            id="vehicle-make"
            name="vehicle-make"
            className="field__select"
            value={vehicleMake}
            onChange={handleMakeChange}
          >
            <option value="">Select make</option>
            {Object.keys(vehicleData).map((make) => (
              <option key={make} value={make}>
                {make}
              </option>
            ))}
          </select>
        </label>

        <label className="field" htmlFor="vehicle-model">
          <span className="field__label">Vehicle Model</span>
          <select
            id="vehicle-model"
            name="vehicle-model"
            className="field__select"
            value={vehicleModel}
            onChange={(event) => setVehicleModel(event.target.value)}
            disabled={!vehicleMake}
          >
            <option value="">Select model</option>
            {modelOptions.map((model) => (
              <option key={model} value={model}>
                {model}
              </option>
            ))}
          </select>
        </label>
      </div>

      <button
        type="button"
        className="primary-button"
        disabled={!canContinue}
        onClick={onContinue}
      >
        SAVE VEHICLE
      </button>
    </section>
  );
}

function StepThree({
  fullName,
  setFullName,
  shippingDate,
  setShippingDate,
  email,
  setEmail,
  phone,
  setPhone,
}) {
  const canCalculate =
    fullName.trim().length > 0 &&
    shippingDate.trim().length > 0 &&
    email.trim().length > 0 &&
    phone.trim().length > 0;

  return (
    <section className="quote-card" aria-labelledby="contact-step-title">
      <div className="quote-card__header">
        <p className="quote-card__eyebrow">Step 3</p>
        <h1 id="contact-step-title">Contact details and shipping date</h1>
      </div>

      <div className="form-grid">
        <label className="field" htmlFor="full-name">
          <span className="field__label">Full Name</span>
          <input
            id="full-name"
            name="full-name"
            className="field__input"
            type="text"
            value={fullName}
            onChange={(event) => setFullName(event.target.value)}
          />
        </label>

        <label className="field" htmlFor="shipping-date">
          <span className="field__label">Shipping Date</span>
          <input
            id="shipping-date"
            name="shipping-date"
            className="field__input"
            type="date"
            value={shippingDate}
            onChange={(event) => setShippingDate(event.target.value)}
          />
        </label>

        <div className="split-grid">
          <label className="field" htmlFor="email">
            <span className="field__label">Email</span>
            <input
              id="email"
              name="email"
              className="field__input"
              type="email"
              value={email}
              onChange={(event) => setEmail(event.target.value)}
            />
          </label>

          <label className="field" htmlFor="phone">
            <span className="field__label">Phone</span>
            <input
              id="phone"
              name="phone"
              className="field__input"
              type="tel"
              value={phone}
              onChange={(event) => setPhone(event.target.value)}
            />
          </label>
        </div>
      </div>

      <button type="button" className="primary-button" disabled={!canCalculate}>
        Calculate Cost
      </button>
    </section>
  );
}

export default function App() {
  const [currentStep, setCurrentStep] = useState(1);
  const [maxUnlockedStep, setMaxUnlockedStep] = useState(1);
  const [pickup, setPickup] = useState("");
  const [delivery, setDelivery] = useState("");
  const [vehicleYear, setVehicleYear] = useState("");
  const [vehicleMake, setVehicleMake] = useState("");
  const [vehicleModel, setVehicleModel] = useState("");
  const [fullName, setFullName] = useState("");
  const [shippingDate, setShippingDate] = useState("");
  const [email, setEmail] = useState("");
  const [phone, setPhone] = useState("");

  const advanceToStep = (nextStep) => {
    setCurrentStep(nextStep);
    setMaxUnlockedStep((prev) => Math.max(prev, nextStep));
  };

  return (
    <main className="page-shell">
      <div className="page-shell__glow page-shell__glow--left" aria-hidden="true" />
      <div className="page-shell__glow page-shell__glow--right" aria-hidden="true" />

      <section className="quote-panel" aria-label="Transport quote form">
        <div className="step-bar" role="tablist" aria-label="Quote form steps">
          {stepMeta.map((step) => (
            <StepPill
              key={step.id}
              id={step.id}
              label={step.label}
              currentStep={currentStep}
              maxUnlockedStep={maxUnlockedStep}
              onSelect={setCurrentStep}
            />
          ))}
        </div>

        {currentStep === 1 ? (
          <StepOne
            pickup={pickup}
            delivery={delivery}
            setPickup={setPickup}
            setDelivery={setDelivery}
            onContinue={() => advanceToStep(2)}
          />
        ) : null}

        {currentStep === 2 ? (
          <StepTwo
            vehicleYear={vehicleYear}
            setVehicleYear={setVehicleYear}
            vehicleMake={vehicleMake}
            setVehicleMake={setVehicleMake}
            vehicleModel={vehicleModel}
            setVehicleModel={setVehicleModel}
            onContinue={() => advanceToStep(3)}
          />
        ) : null}

        {currentStep === 3 ? (
          <StepThree
            fullName={fullName}
            setFullName={setFullName}
            shippingDate={shippingDate}
            setShippingDate={setShippingDate}
            email={email}
            setEmail={setEmail}
            phone={phone}
            setPhone={setPhone}
          />
        ) : null}
      </section>
    </main>
  );
}
EOF

cat > /app/src/styles.css <<'EOF'
:root {
  font-family: "Segoe UI", "Helvetica Neue", Arial, sans-serif;
  color: #11261b;
  background:
    radial-gradient(circle at top left, rgba(104, 205, 134, 0.28), transparent 28rem),
    radial-gradient(circle at bottom right, rgba(255, 213, 120, 0.22), transparent 24rem),
    linear-gradient(135deg, #f6fbf4 0%, #edf7ef 45%, #f9f5ea 100%);
}

* {
  box-sizing: border-box;
}

body {
  margin: 0;
  min-width: 320px;
}

button,
input {
  font: inherit;
}

.page-shell {
  position: relative;
  min-height: 100vh;
  display: grid;
  place-items: center;
  padding: 32px 16px;
  overflow: hidden;
}

.page-shell__glow {
  position: absolute;
  width: 20rem;
  height: 20rem;
  border-radius: 999px;
  filter: blur(18px);
  opacity: 0.7;
}

.page-shell__glow--left {
  top: 3rem;
  left: -6rem;
  background: rgba(55, 161, 92, 0.18);
}

.page-shell__glow--right {
  right: -5rem;
  bottom: 2rem;
  background: rgba(232, 177, 87, 0.16);
}

.quote-panel {
  position: relative;
  z-index: 1;
  width: min(100%, 430px);
  padding: 18px;
  border: 1px solid rgba(17, 38, 27, 0.08);
  border-radius: 28px;
  background: rgba(255, 255, 255, 0.88);
  box-shadow: 0 24px 70px rgba(29, 57, 41, 0.14);
  backdrop-filter: blur(10px);
}

.step-bar {
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: 10px;
  margin-bottom: 18px;
}

.step-pill {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 10px 12px;
  border-radius: 18px;
  border: 1px solid transparent;
  background: transparent;
  text-align: left;
}

.step-pill__number {
  display: inline-grid;
  width: 28px;
  height: 28px;
  place-items: center;
  border-radius: 999px;
  font-size: 0.9rem;
  font-weight: 700;
}

.step-pill__label {
  font-size: 0.92rem;
  font-weight: 600;
}

.step-pill--current {
  border-color: rgba(45, 150, 84, 0.22);
  background: linear-gradient(180deg, #f5fff8 0%, #effaf2 100%);
  color: #145530;
  box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.65);
}

.step-pill--current .step-pill__number {
  background: #2d9654;
  color: #fff;
}

.step-pill--locked {
  color: rgba(17, 38, 27, 0.55);
  background: rgba(239, 244, 240, 0.88);
  cursor: not-allowed;
}

.step-pill--locked .step-pill__number {
  background: rgba(17, 38, 27, 0.08);
  color: rgba(17, 38, 27, 0.72);
}

.step-pill--available {
  color: #21442d;
  background: rgba(248, 251, 248, 0.95);
  border-color: rgba(17, 38, 27, 0.08);
}

.step-pill--available .step-pill__number {
  background: rgba(45, 150, 84, 0.14);
  color: #1e7b42;
}

.quote-card {
  padding: 22px;
  border-radius: 24px;
  background:
    linear-gradient(180deg, rgba(255, 255, 255, 0.95), rgba(248, 252, 249, 0.95));
  border: 1px solid rgba(19, 45, 31, 0.08);
}

.quote-card__header h1 {
  margin: 6px 0 10px;
  font-size: clamp(1.6rem, 5vw, 2rem);
  line-height: 1.1;
}

.quote-card__eyebrow {
  margin: 0;
  font-size: 0.78rem;
  font-weight: 700;
  letter-spacing: 0.18em;
  text-transform: uppercase;
  color: #2d9654;
}

.quote-card__subcopy {
  margin: 0 0 18px;
  color: rgba(17, 38, 27, 0.68);
  line-height: 1.5;
}

.location-box {
  position: relative;
  display: grid;
  gap: 14px;
  padding: 16px;
  margin-bottom: 18px;
  border-radius: 22px;
  border: 1px solid rgba(22, 52, 35, 0.12);
  background: #fbfdfb;
}

.field {
  display: grid;
  gap: 8px;
}

.field__label {
  font-size: 0.92rem;
  font-weight: 700;
}

.field__control {
  display: flex;
  align-items: center;
  gap: 10px;
  min-height: 56px;
  padding: 0 14px;
  border: 1px solid rgba(17, 38, 27, 0.12);
  border-radius: 16px;
  background: #fff;
  box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.8);
}

.field__control:focus-within {
  border-color: rgba(45, 150, 84, 0.55);
  box-shadow: 0 0 0 4px rgba(45, 150, 84, 0.1);
}

.field__icon {
  font-size: 1rem;
  font-weight: 700;
  color: #1e7b42;
}

.field input {
  width: 100%;
  border: 0;
  outline: none;
  background: transparent;
  color: inherit;
}

.field__input,
.field__select {
  width: 100%;
  min-height: 56px;
  padding: 0 14px;
  border: 1px solid rgba(17, 38, 27, 0.12);
  border-radius: 16px;
  outline: none;
  background: #fff;
  color: inherit;
}

.field__input:focus,
.field__select:focus {
  border-color: rgba(45, 150, 84, 0.55);
  box-shadow: 0 0 0 4px rgba(45, 150, 84, 0.1);
}

.field input::placeholder {
  color: rgba(17, 38, 27, 0.38);
}

.form-grid {
  display: grid;
  gap: 14px;
  margin-bottom: 18px;
}

.split-grid {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 14px;
}

.swap-button {
  position: absolute;
  right: 18px;
  top: 73px;
  display: inline-grid;
  place-items: center;
  width: 38px;
  height: 38px;
  border: 1px solid rgba(45, 150, 84, 0.16);
  border-radius: 12px;
  background: linear-gradient(180deg, #ffffff 0%, #f2fbf5 100%);
  color: #1e7b42;
  box-shadow: 0 10px 20px rgba(38, 89, 57, 0.08);
  cursor: pointer;
}

.primary-button {
  width: 100%;
  min-height: 54px;
  border: 0;
  border-radius: 16px;
  background: linear-gradient(180deg, #35b45d 0%, #2d9654 100%);
  color: #fff;
  font-size: 0.95rem;
  font-weight: 800;
  letter-spacing: 0.06em;
  box-shadow: 0 16px 28px rgba(45, 150, 84, 0.24);
}

.primary-button:disabled {
  background: linear-gradient(180deg, #b7d7c0 0%, #9ebea7 100%);
  box-shadow: none;
  cursor: not-allowed;
}

@media (max-width: 520px) {
  .quote-panel {
    padding: 14px;
    border-radius: 22px;
  }

  .step-bar {
    gap: 8px;
  }

  .step-pill {
    flex-direction: column;
    align-items: flex-start;
    gap: 6px;
    min-height: 84px;
  }

  .quote-card {
    padding: 18px;
  }

  .swap-button {
    top: 78px;
  }

  .split-grid {
    grid-template-columns: 1fr;
  }
}
EOF

cd /app
npm install
npm run build
