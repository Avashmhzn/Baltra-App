import 'package:baltra/features/applicationCare/presentation/ui/product_maintainance_page.dart';
import 'package:flutter/material.dart';

class ProductTrackingCard extends StatelessWidget {
  const ProductTrackingCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const ProductMaintainancePage()));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        height: 180,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.grey)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: const SizedBox(
                height: 150,
                width: 100,
                child: ClipRRect(
                  child: Image(
                    image: AssetImage('assets/images/blender.png'),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Blender  Crush 3',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    'BMG 174',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: Table(
                      border: const TableBorder.symmetric(
                        outside: BorderSide.none,
                        // Inner border
                      ),
                      children: const [
                        TableRow(
                          children: [
                            TableCell(
                              child: Text('Tracking ID',
                                  style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500)),
                            ),
                            TableCell(
                              child: Text(
                                '2281929',
                                style: TextStyle(fontSize: 10),
                              ),
                            ),
                          ],
                        ),
                        TableRow(
                          children: [
                            TableCell(
                              child: Text('Sent for',
                                  style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500)),
                            ),
                            TableCell(
                              child: Text(
                                'Repair',
                                style: TextStyle(fontSize: 10),
                              ),
                            ),
                          ],
                        ),
                        TableRow(
                          children: [
                            TableCell(
                              child: Text('Complaint ID',
                                  style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500)),
                            ),
                            TableCell(
                              child: Text(
                                'Blender is broken',
                                style: TextStyle(fontSize: 10),
                              ),
                            ),
                          ],
                        ),
                        TableRow(
                          children: [
                            TableCell(
                              child: Text('Stage',
                                  style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500)),
                            ),
                            TableCell(
                              child: Text(
                                'Satge 2',
                                style: TextStyle(fontSize: 10),
                              ),
                            ),
                          ],
                        ),
                        TableRow(
                          children: [
                            TableCell(
                              child: Text('Sent date',
                                  style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500)),
                            ),
                            TableCell(
                              child: Text(
                                '24th March, 2024',
                                style: TextStyle(fontSize: 10),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
