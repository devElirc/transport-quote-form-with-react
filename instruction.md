Build a transport quote form as a single-page frontend.
Use the existing static page setup in this repo. Do not scaffold a new React or Vite app. 

The quote form on the home page is a small card with 2 steps.
At the top, show a step bar with Destination and Vehicle. The current step should stand out clearly.
Users should not be able to open future steps before reaching them.
Under the step bar, show the content for the current step inside the same card.

Step 1 is for pickup and delivery. The title is "Transport car pickup and destination."
Show two stacked fields inside a bordered box. The first field is Pickup with a small search icon.
The second field is Delivery with a small flag icon.
Use accessible labels so the inputs can be found as Pickup and Delivery.
Under this section, there is a full-width green button labeled "VEHICLE DETAILS".
Users can enter a city or ZIP code in both fields, like "Los Angeles" and "Houston".
Clicking the button should move to Step 2 only after both fields are filled in. If either field is blank, keep Step 2 locked and show the validation message "Please enter both pickup and delivery locations."

Step 2 is for vehicle details.
Show fields for Vehicle Year, Vehicle Make, and Vehicle Model.
Use accessible labels so the controls can be found as Vehicle Year, Vehicle Make, and Vehicle Model.
Users can type a year or select one from a dropdown.
The year list should start from the current year and go down to 1980.
Vehicle Make can use mocked vehicle data.
Vehicle Model must stay disabled until a make is selected. After the make is selected, load the model options for that make.
Include mocked makes and models so selecting Toyota enables model choices including Camry, Corolla, RAV4, and Tacoma.
Add a "SAVE Calculate Cost" button under the fields.
