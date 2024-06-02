import 'package:flutter/material.dart';
import 'package:titosapp/util/CustomColor.dart';

class NumericStepButton extends StatefulWidget {
  final int minValue;
  final int maxValue;

  final TextEditingController textEditingController;
  final VoidCallback onPlus;
  final VoidCallback onMinus;

  NumericStepButton(
      {Key? key,
      this.minValue = 0,
      this.maxValue = 10,
      required this.textEditingController,
      required this.onPlus,
      required this.onMinus})
      : super(key: key);

  @override
  State<NumericStepButton> createState() {
    return _NumericStepButtonState();
  }
}

class _NumericStepButtonState extends State<NumericStepButton> {
  int counter = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: CustomColor.white,
        border: Border.all(color: CustomColor.colorBorder),
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: Icon(
              Icons.remove,
            ),
            padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 18.0),
            iconSize: 32.0,
            onPressed: () {
              widget.onMinus();
              setState(() {
                if (counter > widget.minValue) {
                  counter--;
                }
                widget.textEditingController.text = counter.toString();
              });
            },
          ),
          Text(
            '$counter',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black87,
              fontSize: 18.0,
              fontWeight: FontWeight.w500,
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.add,
            ),
            padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 18.0),
            iconSize: 32.0,
            onPressed: () {
              widget.onPlus();

              setState(() {
                if (counter < widget.maxValue) {
                  counter++;
                }
                widget.textEditingController.text = counter.toString();
              });
            },
          ),
        ],
      ),
    );
  }
}
