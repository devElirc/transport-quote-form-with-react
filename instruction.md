Build a transport quote form with react.js.
The quote form on the home page is a small card with 3 steps.
At the top, show a step bar with Destination, Vehicle, and Date. The current step should stand out clearly.
Users should not be able to open future steps before reaching them.
Under the step bar, show the content for the current step inside the same card.

Step 1 is for pickup and delivery. The title is "Transport car pickup and destination." 
Show two stacked fields inside a bordered box. The first field is Pickup with a small search icon. 
The second field is Delivery with a small flag icon. 
Between them, on the right side, add a small swap button. 
This button should switch the Pickup and Delivery values. 
Under this section, there is a full-width green button labeled "VEHICLE DETAILS". 
Users can enter a city or ZIP code in both fields, like "Los Angeles" and "Houston".
And then click the button to moves the Step 2.

Step 2 is for vehicle details.
Show fields for Vehicle Year, Vehicle Make, and Vehicle Model. 
Users can type year or select year from a dropdown.
The list should start from the current year and go down to 1980. 
Vehicle Make should load from real vehicle data but now we can use mockdata. Model should stay disabled until a make is selected. After the make is selected, load the model options. Add a "SAVE VEHICLE" button under the fields.


Step 3 is for contact details and shipping date. Show a simple form with full name and shipping date. Use a date picker for the shipping date. Below that, show email and phone number in two columns. 
At the bottom, show a green button labeled "Calculate Cost."
