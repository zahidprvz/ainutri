import 'package:ainutri/provider/payment_provider.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:provider/provider.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({Key? key}) : super(key: key);

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  String _couponCode = '';

  @override
  Widget build(BuildContext context) {
    final paymentProvider = Provider.of<PaymentProvider>(context);

    if (!paymentProvider.isAvailable) {
      return Scaffold(
        body: Center(
          child: Text("In-App Purchases are not available on this device."),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Subscription"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "Unlock all features with a premium subscription!",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            ...paymentProvider.products.map((ProductDetails product) {
              // Display the product details and a buy button
              return ListTile(
                title: Text(product.title),
                subtitle: Text(product.description),
                trailing: Text(product.price),
                onTap: () {
                  paymentProvider.buySubscription(product);
                },
              );
            }).toList(),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      decoration:
                          InputDecoration(hintText: "Enter coupon code"),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a coupon code';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _couponCode = value!;
                      },
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          paymentProvider.applyCouponCode(_couponCode);
                        }
                      },
                      child: Text("Apply Coupon"),
                    ),
                  ],
                ),
              ),
            ),
            if (paymentProvider.purchasePending) CircularProgressIndicator(),
            if (paymentProvider.error != null)
              Text("Error: ${paymentProvider.error}"),
          ],
        ),
      ),
    );
  }
}
