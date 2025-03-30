import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Privacy Policy',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                'Last updated: October 1, 2023',
                style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
              ),
              SizedBox(height: 16),
              Text(
                '1. Introduction',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                """At DPROFIZ PVT. LTD., accessible from "dprofiz.com", one of our main priorities is the privacy of our visitors. This Privacy Policy document contains types of information that is collected and recorded by DPROFIZ PVT. LTD. and how we use it.\n
If you have additional questions or require more information about our Privacy Policy, do not hesitate to contact us.\n
This Privacy Policy applies only to our online activities and is valid for visitors to our website with regards to the information that they shared and/or collect in DPROFIZ PVT. LTD.. This policy is not applicable to any information collected offline or via channels other than this website. Our Privacy Policy was created with the help of the ToolsPrince Privacy Policy Generator.""",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                '2. Consent',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                """By using our application, you hereby consent to our Privacy Policy and agree to its terms.

Information we collect
The personal information that you are asked to provide, and the reasons why you are asked to provide it, will be made clear to you at the point we ask you to provide your personal information.

If you contact us directly, we may receive additional information about you such as your name, email address, phone number, the contents of the message and/or attachments you may send us, and any other information you may choose to provide.

When you register for an Account, we may ask for your contact information, including items such as name, company name, address, email address, and telephone number.""",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                '3. How We Use Your Information',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                """We use the information we collect in various ways, including to:

Provide, operate, and maintain our website
Improve, personalize, and expand our website
Understand and analyze how you use our website
Develop new products, services, features, and functionality
Communicate with you, either directly or through one of our partners, including for customer service, to provide you with updates and other information relating to the website, and for marketing and promotional purposes
Send you emails
Find and prevent fraud
Log Files
DPROFIZ PVT. LTD. follows a standard procedure of using log files. These files log visitors when they visit websites. All hosting companies do this and a part of hosting services analytics. The information collected by log files include internet protocol (IP) addresses, browser type, Internet Service Provider (ISP), date and time stamp, referring/exit pages, and possibly the number of clicks. These are not linked to any information that is personally identifiable. The purpose of the information is for analyzing trends, administering the site, tracking the movement of the users on the website, and gathering demographic information.""",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                '4. Cookies and Similar Technologies',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                """ookies and Web Beacons
Like any other website, DPROFIZ PVT. LTD. uses "cookies". These cookies are used to store information including the preferences of the visitors and the pages on the website that the visitor accessed or visited. The information is used to optimize the users experience by customizing our web page content based on the browser type of the visitors and/or other information.

Google DoubleClick DART Cookie
Google is one of a third-party vendor on our site. It also uses cookies, known as DART cookies, to serve ads to our site visitors based upon their visit to www.website.com and other sites on the internet. However, visitors may choose to decline the use of DART cookies by visiting the Google ad and content network Privacy Policy at the following URL - https://policies.google.com/technologies/ads

Our Advertising Partners
Some of advertisers on our site may use cookies and web beacons. Our advertising partners are listed below. Each of our advertising partners has their own Privacy Policy for their policies on user data. For easier access, we hyperlinked to their Privacy Policies below.""",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                '5. Advertising Partners Privacy Policies',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                """You may consult this list to find the Privacy Policy for each of the advertising partners of DPROFIZ PVT. LTD..

Third-party ad servers or ad networks uses technologies like cookies, JavaScript, or Web Beacons that are used in their respective advertisements and links that appear on DPROFIZ PVT. LTD., which are sent directly to the browser of users. They automatically receive your IP address when this occurs. These technologies are used to measure the effectiveness of their advertising campaigns and/or to personalize the advertising content that you see on websites that you visit.

Note that DPROFIZ PVT. LTD. has no access to or control over these cookies that are used by third-party advertisers.""",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                '6. Third Party Privacy Policies',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                """DPROFIZ PVT. LTD.;s Privacy Policy does not apply to other advertisers or websites. Thus, we are advising you to consult the respective Privacy Policies of these third-party ad servers for more detailed information. It may include their practices and instructions about how to opt-out of certain options.

You can choose to disable cookies through your individual browser options. To know more detailed information about cookie management with specific web browsers, it can be found at the browsers respective websites.""",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16,),

              Text(
                '7. CCPA Privacy Rights (Do Not Sell My Personal Information)',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                """Under the CCPA, among other rights, California consumers have the right to:

Request that a business that collects a personal data of the consumers, disclose the categories and specific pieces of personal data that a business has collected about consumers.

Request that a business delete any personal data about the consumer that a business has collected.

Request that a business that sells a personal data of consumers, not sell the personal data of consumers.

If you make a request, we have one month to respond to you. If you would like to exercise any of these rights, please contact us.""",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16,),
              Text(
                '8. Contact Us',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                "info.dprofiz@gmail.com",
                style: TextStyle(fontSize: 16),
              ),
    
            ],
          ),
        ),
      ),
    );
  }
}
