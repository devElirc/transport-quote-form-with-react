Build a transport quote form with react.js.
The quote form on the home page is a small card with 2 steps.
At the top, show a step bar with Destination, Vehicle. The current step should stand out clearly.
Users should not be able to open future steps before reaching them.
Under the step bar, show the content for the current step inside the same card.

Step 1 is for pickup and delivery. The title is "Transport car pickup and destination." 
Show two stacked fields inside a bordered box. The first field is Pickup with a small search icon. 
The second field is Delivery with a small flag icon. 
Under this section, there is a full-width green button labeled "VEHICLE DETAILS". 
Users can enter a city or ZIP code in both fields, like "Los Angeles" and "Houston".
And then click the button to moves the Step 2.

Step 2 is for vehicle details.
Show fields for Vehicle Year, Vehicle Make, and Vehicle Model. 
Users can type year or select year from a dropdown.
The list should start from the current year and go down to 1980. 
Vehicle Make should load from real vehicle data but now we can use mockdata. Model should stay disabled until a make is selected. After the make is selected, load the model options. Add a "SAVE Calculate Cost" button under the fields.

