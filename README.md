# Cartify
mini e-commerce flutter app by firebase

## Getting Started

steps for installing and running app:
- open the project folder named 'first' in the android studio
- first\build and first\android\app\.cxx should be deleted if it is found
- run the commands:
  flutter pub get
  flutter run
- then the app will be installed in your emulator or mobile that you are connected.
- or your can get apk from build/app/outputs/flutter-apk/app-debug.apk
- when you open the app, it will go to login page, mainly there are two portals:

1. Admin Portal
   email:acartify@gmail.com
   password:Admin@123

In this portal, you can add new products with min one variant, along with img url link in google drive by allowing everyone permission in it (img_picker is used but firebase requires paid version for storage of img in database).
Also, you can view the orders by different users and profile page in this portal.

2. User Portal
   For entering this portal, either you can Google login or you can register new account by entering your original mail_id and password along with your desired username.

In this portal you can view the home page add the necessary products to the cart.
It may take some time to load the images from drive.
In cart, you can take the number of products and order.
When the order is clicked the items in the cart is been ordered and you can see your orders in myorders in the appbar.
You can get payment details after order now the product with the preffered payment method.
Also, you can filter the products by using the search bar at the top.
Also, you can see your profile in profile side along with your role.

I've not done the Google map services for getting the nearby stores because Google Api is a paid service.
Also not done stripe because it requires company name for registering for getting its api for integration.