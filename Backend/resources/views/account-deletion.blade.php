<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Docuhealth Account Deletion</title>
    <style>
        body {
            margin: 0;
            font-family: Arial, sans-serif;
            background: #f4f7fb;
            color: #1f2937;
        }

        .container {
            max-width: 760px;
            margin: 0 auto;
            padding: 32px 20px 48px;
        }

        .card {
            background: #ffffff;
            border-radius: 16px;
            padding: 24px;
            box-shadow: 0 18px 40px rgba(15, 23, 42, 0.08);
        }

        h1 {
            margin-top: 0;
            font-size: 32px;
        }

        p,
        li,
        label {
            line-height: 1.6;
        }

        .notice {
            padding: 14px 16px;
            border-radius: 10px;
            margin-bottom: 18px;
        }

        .notice-success {
            background: #ecfdf3;
            color: #166534;
            border: 1px solid #a7f3d0;
        }

        .notice-error {
            background: #fef2f2;
            color: #991b1b;
            border: 1px solid #fecaca;
        }

        .grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 16px;
        }

        .field {
            margin-bottom: 16px;
        }

        input,
        textarea {
            width: 100%;
            padding: 12px 14px;
            border: 1px solid #d1d5db;
            border-radius: 10px;
            box-sizing: border-box;
            font-size: 15px;
        }

        textarea {
            min-height: 120px;
            resize: vertical;
        }

        .button {
            display: inline-block;
            border: 0;
            border-radius: 10px;
            background: #0f766e;
            color: #ffffff;
            padding: 12px 18px;
            font-size: 15px;
            font-weight: 700;
            cursor: pointer;
        }

        .muted {
            color: #6b7280;
        }

        @media (max-width: 640px) {
            .grid {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="card">
            <h1>Docuhealth account deletion</h1>
            <p>
                Use this page if you want to request deletion of your Docuhealth account without using the app.
                If you still have access to the app, you can also delete your account directly from the Profile screen.
            </p>

            <ul>
                <li>Your request should include the same phone number or email address linked to the account.</li>
                <li>Deleting an account permanently removes access to the account and associated profiles.</li>
                <li>Some records may be retained where required for legal, security, or fraud-prevention reasons.</li>
            </ul>

            @if (session('success'))
                <div class="notice notice-success">{{ session('success') }}</div>
            @endif

            @if ($errors->any())
                <div class="notice notice-error">
                    <strong>We could not submit your request:</strong>
                    <ul>
                        @foreach ($errors->all() as $error)
                            <li>{{ $error }}</li>
                        @endforeach
                    </ul>
                </div>
            @endif

            <form method="POST" action="{{ route('account-deletion.store') }}">
                @csrf

                <div class="grid">
                    <div class="field">
                        <label for="name">Full name</label>
                        <input id="name" name="name" type="text" value="{{ old('name') }}" maxlength="100">
                    </div>

                    <div class="field">
                        <label for="phone">Phone number</label>
                        <input id="phone" name="phone" type="text" value="{{ old('phone') }}" maxlength="30">
                    </div>
                </div>

                <div class="field">
                    <label for="email">Email address</label>
                    <input id="email" name="email" type="email" value="{{ old('email') }}" maxlength="255">
                </div>

                <div class="field">
                    <label for="message">Additional details</label>
                    <textarea id="message" name="message" maxlength="1000">{{ old('message') }}</textarea>
                </div>

                <button type="submit" class="button">Submit deletion request</button>
            </form>

            <p class="muted">
                Keep this page public and use its full URL in Google Play Console for the outside-app account deletion link.
            </p>
        </div>
    </div>
</body>
</html>
