<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\CMS;
use App\Library\Structure;
use App\Library\Beautify;

class CMSController extends Controller
{
    use Structure;

    public function about(Request $request)
    {
        $about = CMS::where('name', 'about-page')->where('is_active', 'Yes')->select('name', 'content', 'tags')->first();

        if ($about) {
            return response()->json($this->structure(true, "", $about), 200);
        }

        return response()->json($this->structure(true, "", [
            'name' => 'about-page',
            'content' => $this->fallbackAboutContent(),
            'tags' => null,
        ]), 200);
    }

    public function contact_us(Request $request)
    {
        $contact_us = CMS::where('name', 'contact-us-page')->where('is_active', 'Yes')->select('name', 'content', 'tags')->first();

        if ($contact_us) {
            return response()->json($this->structure(true, "", $contact_us), 200);
        }

        return response()->json($this->structure(true, "", [
            'name' => 'contact-us-page',
            'content' => $this->fallbackContactUsContent(),
            'tags' => null,
        ]), 200);
    }

    public function privacy_policy(Request $request)
    {
        $privacy_policy = CMS::where('name', 'privacy-policy-page')->where('is_active', 'Yes')->select('name', 'content', 'tags')->first();

        if ($privacy_policy) {
            return response()->json($this->structure(true, "", $privacy_policy), 200);
        }

        return response()->json($this->structure(true, "", [
            'name' => 'privacy-policy-page',
            'content' => $this->fallbackPrivacyPolicyContent(),
            'tags' => null,
        ]), 200);
    }

    public function terms_and_conditions(Request $request)
    {
        $terms_and_conditions = CMS::where('name', 'terms-and-conditions-page')->where('is_active', 'Yes')->select('name', 'content', 'tags')->first();

        if ($terms_and_conditions) {
            return response()->json($this->structure(true, "", $terms_and_conditions), 200);
        }

        return response()->json($this->structure(true, "", [
            'name' => 'terms-and-conditions-page',
            'content' => $this->fallbackTermsContent(),
            'tags' => null,
        ]), 200);
    }

    private function fallbackPrivacyPolicyContent(): string
    {
        return <<<HTML
<p>This Privacy Policy explains how Docuhealth collects, uses, stores, and shares information when you use the Docuhealth mobile application and related services.</p>

<h2>Who this policy applies to</h2>
<p>This policy applies to users of the Docuhealth app and related services, including account creation, profile management, document storage, health measurement tracking, reminder features, nearby search, notifications, and connected device features.</p>

<h2>Information we collect</h2>
<ul>
  <li>Account information such as phone number, email address, name, and profile details.</li>
  <li>Profile information such as date of birth, gender, relation, profile image, and linked family profiles.</li>
  <li>Health and medical record information, including uploaded files, reports, reminders, daily measurements, and device vitals.</li>
  <li>Device and app information such as device token, basic technical information, and logs needed to operate the service.</li>
  <li>Location information when you use features such as profile location or nearby doctor and pharmacy search.</li>
  <li>Camera, image, file, and Bluetooth data when you use scanning, upload, sharing, or connected device features.</li>
</ul>

<h2>How we use information</h2>
<ul>
  <li>To create and manage your account and profiles.</li>
  <li>To store, display, organize, and share documents and medical records at your direction.</li>
  <li>To record and display daily health measurements and device-generated vitals.</li>
  <li>To provide reminders, notifications, account security, and in-app support features.</li>
  <li>To support nearby service discovery, profile updates, and app functionality.</li>
  <li>To maintain, troubleshoot, secure, and improve the service.</li>
</ul>

<h2>How information may be shared</h2>
<ul>
  <li>With service providers and infrastructure providers that help operate the app.</li>
  <li>With linked family members or other recipients when you choose to share files or records through the app.</li>
  <li>When required by law, regulation, legal process, or to protect users, the service, or the public.</li>
</ul>

<h2>Data retention and deletion</h2>
<p>We retain information for as long as needed to provide the service, meet operational needs, resolve disputes, prevent fraud and abuse, and comply with legal obligations. You can request account deletion from within the app or through the public deletion request page at <a href="/account-deletion">/account-deletion</a>.</p>

<h2>Security</h2>
<p>We use administrative and technical measures intended to protect user information. However, no method of storage or transmission is completely secure, and we cannot guarantee absolute security.</p>

<h2>Your choices</h2>
<ul>
  <li>You may update profile information through the app where those features are available.</li>
  <li>You may control permissions such as camera, files, Bluetooth, notifications, and location through your device settings.</li>
  <li>You may request account deletion using the in-app delete-account feature or the public deletion page.</li>
</ul>

<h2>Children</h2>
<p>Docuhealth is not intended to be used by children without appropriate supervision or authorization from a parent, guardian, or other authorized adult where required.</p>

<h2>Contact and privacy requests</h2>
<p>For privacy questions or deletion-related requests, use the public request page at <a href="/account-deletion">/account-deletion</a>.</p>
HTML;
    }

    private function fallbackAboutContent(): string
    {
        return <<<HTML
<p>Docuhealth is a personal health record and document management application designed to help users organize, access, and manage their health-related information from one place.</p>

<h2>What Docuhealth helps you do</h2>
<ul>
  <li>Store and organize health records and uploaded files.</li>
  <li>Track daily measurements and connected-device vitals.</li>
  <li>Manage reminders and profile information.</li>
  <li>Access nearby healthcare-related services and information.</li>
  <li>Share selected records with linked family profiles where available.</li>
</ul>

<h2>Frequently asked questions</h2>
<p><strong>Is Docuhealth a medical provider?</strong><br>Docuhealth is a software platform for managing health-related records and information. It does not replace professional medical advice, diagnosis, or treatment.</p>

<p><strong>Can I upload my medical documents?</strong><br>Yes. The app supports document and image upload, storage, and viewing features.</p>

<p><strong>Can I delete my account?</strong><br>Yes. You can request account deletion inside the app or on the public deletion page at <a href="/account-deletion">/account-deletion</a>.</p>

<p><strong>Where can I read the privacy policy?</strong><br>You can read it at <a href="/privacy-policy">/privacy-policy</a>.</p>
HTML;
    }

    private function fallbackContactUsContent(): string
    {
        return <<<HTML
<p>If you need help with Docuhealth, use the information below to contact the support team.</p>

<h2>Support</h2>
<ul>
  <li>For account deletion and privacy-related requests, use <a href="/account-deletion">/account-deletion</a>.</li>
  <li>For general support, contact the Docuhealth administrator through the details configured for your deployment.</li>
</ul>

<h2>Before contacting support</h2>
<ul>
  <li>Include the phone number or email linked to your account.</li>
  <li>Describe the issue clearly, including the screen or feature involved.</li>
  <li>If relevant, mention whether the issue is related to uploads, reminders, login, BLE devices, or notifications.</li>
</ul>
HTML;
    }

    private function fallbackTermsContent(): string
    {
        return <<<HTML
<p>By using Docuhealth, you agree to use the application responsibly and only for lawful purposes.</p>

<h2>Use of the service</h2>
<ul>
  <li>You are responsible for the accuracy of the information you upload or enter.</li>
  <li>You must not misuse the service, attempt unauthorized access, or interfere with normal app operations.</li>
  <li>You are responsible for maintaining access to your device and account.</li>
</ul>

<h2>Health information disclaimer</h2>
<p>Docuhealth is intended to help users manage and review health-related information. It is not a substitute for professional medical judgment, diagnosis, or treatment.</p>

<h2>Content and availability</h2>
<p>Features, content, and availability may change over time. Access to some functions may depend on device support, permissions, backend availability, or third-party services.</p>

<h2>Account and deletion</h2>
<p>You may stop using the service at any time. If you want your account deleted, use the in-app deletion option or the public deletion page at <a href="/account-deletion">/account-deletion</a>.</p>

<h2>Privacy</h2>
<p>Your use of Docuhealth is also governed by the Privacy Policy available at <a href="/privacy-policy">/privacy-policy</a>.</p>
HTML;
    }
}
