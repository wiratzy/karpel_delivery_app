import 'package:flutter/material.dart';
import 'package:kons2/common/color_extension.dart';
import 'package:kons2/common_widget/round_icon_button.dart';
import 'package:kons2/common_widget/round_textfield.dart';

class AddCardView extends StatefulWidget {
  const AddCardView({super.key});

  @override
  State<AddCardView> createState() => _AddCardViewState();
}

class _AddCardViewState extends State<AddCardView> {
  TextEditingController txtCardNumber = TextEditingController();
  TextEditingController txtCardMonth = TextEditingController();
  TextEditingController txtCardYear = TextEditingController();
  TextEditingController txtCardCode = TextEditingController();
  TextEditingController txtFirstName = TextEditingController();
  TextEditingController txtLastName = TextEditingController();
  bool isAnyTime = false;

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return  Material(
          color: Colors.transparent, // Biar transparan dan cuma kontennya aja yg styled

      child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
          width: media.width,
          decoration: BoxDecoration(
              color: Tcolor.white,
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20))),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Add Credit/Debit Card",
                    style: TextStyle(
                        color: Tcolor.primaryText,
                        fontSize: 14,
                        fontWeight: FontWeight.w500),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(
                      Icons.close,
                      color: Tcolor.primaryText,
                      size: 25,
                    ),
                  )
                ],
              ),
              Divider(
                color: Tcolor.secondaryText.withOpacity(0.4),
                height: 1,
              ),
              const SizedBox(
                height: 15,
              ),
              RoundTextfield(
                hintText: "Card Number",
                controller: txtCardNumber,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(
                height: 15,
              ),
              Row(
                children: [
                  Text(
                    "Expiry",
                    style: TextStyle(
                        color: Tcolor.primaryText,
                        fontSize: 14,
                        fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: 100,
                    child: RoundTextfield(
                      hintText: "MM",
                      controller: txtCardMonth,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 25),
                  SizedBox(
                    width: 100,
                    child: RoundTextfield(
                      hintText: "YYYY",
                      controller: txtCardYear,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 15,
              ),
              RoundTextfield(
                hintText: "Card Security Code",
                controller: txtCardCode,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(
                height: 15,
              ),
              RoundTextfield(
                hintText: "First Name",
                controller: txtFirstName,
              ),
              const SizedBox(
                height: 15,
              ),
              RoundTextfield(
                hintText: "Last Name",
                controller: txtLastName,
              ),
              const SizedBox(
                height: 15,
              ),
              Row(children: [
                Expanded(
                  child: Text(
                    "You can remove this card at anytime",
                    style: TextStyle(
                        color: Tcolor.secondaryText,
                        fontSize: 14,
                        fontWeight: FontWeight.w500),
                  ),
                ),
                const Spacer(),
                Switch(
                    value: isAnyTime,
                    activeColor: Tcolor.primary,
                    onChanged: (newVal) {
                      setState(() {
                        isAnyTime = newVal;
                      });
                    })
              ]),
              const SizedBox(
                height: 25,
              ),
              RoundIconButton(
                  title: "Add Card",
                  icon: "assets/img/add.png",
                  color: Tcolor.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  onPressed: () {}),
            ],
          ),
        
      ),
    );
  }
}