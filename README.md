# Beachy
![Logo](/beaches/assets/Banner.jpg)

#### General
**Beachy** is a platform that uses a **Dart/Flutter** front-end and a **Node/JavaScript** back-end hosted on **Firebase**. Beachy works with organizations to get their cleanups on our feed. Then our users can find out about them on their homepage stream. They can click on each event to find out more information about it, and can sign up in advance.

#### How it's used
Once the event has started, the game begins. As the users they are picking up each peice of trash they take a picture and select a category for it. The categories are **plastic, metal, paper, hazardous** *(when users click hazardous a dialog comes up advising them not to touch it)*. The data is then sent to our backend. We give more detailed analysis than ever possible before by using **Google's Vision API**. Not only does the organization have access to a **photo** of every single peice of trash recorded, the **material** and the exact **object** are also recorded for their convenience. At the end of the cleanup, the organizers will have all the information of the event, **without** the need for paper.
