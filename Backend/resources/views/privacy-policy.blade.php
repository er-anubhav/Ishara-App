<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Docuhealth Privacy Policy</title>
    <style>
        body {
            margin: 0;
            font-family: Arial, sans-serif;
            background: #f4f7fb;
            color: #1f2937;
        }

        .container {
            max-width: 860px;
            margin: 0 auto;
            padding: 32px 20px 48px;
        }

        .card {
            background: #ffffff;
            border-radius: 16px;
            padding: 28px;
            box-shadow: 0 18px 40px rgba(15, 23, 42, 0.08);
        }

        h1 {
            margin-top: 0;
            font-size: 34px;
        }

        h2 {
            margin-top: 28px;
            font-size: 22px;
        }

        p,
        li {
            line-height: 1.7;
            font-size: 15px;
        }

        a {
            color: #0f766e;
        }

        .muted {
            color: #6b7280;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="card">
            <h1>Privacy Policy</h1>
            <p class="muted">Last updated: {{ $lastUpdated }}</p>

            @if (!empty($cmsContent))
                {!! $cmsContent !!}
            @else
                <p>
                    This Privacy Policy explains how Docuhealth collects, uses, stores, and shares information when you
                    use the Docuhealth mobile application and related services.
                </p>

                <h2>Who this policy applies to</h2>
                <p>
                    This policy applies to users of the Docuhealth app and related services, including account creation,
                    profile management, document storage, health measurement tracking, reminder features, nearby search,
                    notifications, and connected device features.
                </p>

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
                <p>
                    We retain information for as long as needed to provide the service, meet operational needs, resolve disputes,
                    prevent fraud and abuse, and comply with legal obligations. You can request account deletion from within the app
                    or through the public deletion request page at <a href="/account-deletion">/account-deletion</a>.
                </p>

                <h2>Security</h2>
                <p>
                    We use administrative and technical measures intended to protect user information. However, no method of
                    storage or transmission is completely secure, and we cannot guarantee absolute security.
                </p>

                <h2>Your choices</h2>
                <ul>
                    <li>You may update profile information through the app where those features are available.</li>
                    <li>You may control permissions such as camera, files, Bluetooth, notifications, and location through your device settings.</li>
                    <li>You may request account deletion using the in-app delete-account feature or the public deletion page.</li>
                </ul>

                <h2>Children</h2>
                <p>
                    Docuhealth is not intended to be used by children without appropriate supervision or authorization from a parent,
                    guardian, or other authorized adult where required.
                </p>

                <h2>Contact and privacy requests</h2>
                <p>
                    For privacy questions or deletion-related requests, use the public request page at
                    <a href="/account-deletion">/account-deletion</a>.
                </p>
            @endif
        </div>
    </div>
</body>
</html>
