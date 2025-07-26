# Grafana Contact Points Configuration

This directory contains the configuration files for Grafana Contact Points, which are used to configure notification channels for alerts.

## Files

- `contact-points.yaml` - ConfigMap containing Contact Points configuration
- `notification-policies.yaml` - ConfigMap containing Notification Policies configuration
- `README.md` - This documentation file

## Contact Points

Contact Points define where and how alerts should be sent. The current configuration includes:

### 1. Email Contact Point
- **Type**: Email
- **Settings**: Sends alerts to admin@example.com
- **Status**: Default contact point

### 2. Slack Contact Point
- **Type**: Slack
- **Settings**: Sends alerts to a Slack webhook
- **Note**: Update the webhook URL in the configuration

### 3. Webhook Contact Point
- **Type**: Webhook
- **Settings**: Sends alerts to a custom webhook endpoint
- **Note**: Update the URL in the configuration

### 4. Teams Contact Point
- **Type**: Microsoft Teams
- **Settings**: Sends alerts to a Teams webhook
- **Note**: Update the webhook URL in the configuration

## Notification Policies

Notification Policies define how alerts are routed to Contact Points based on severity:

- **Critical alerts**: Sent to email contact point
- **Warning alerts**: Sent to Slack contact point
- **Default**: All alerts sent to email contact point

## Customization

### To customize email addresses:
Edit `contact-points.yaml` and update the `addresses` field:

```yaml
settings:
  addresses: "your-email@example.com, another-email@example.com"
```

### To customize Slack webhook:
Edit `contact-points.yaml` and update the Slack URL:

```yaml
settings:
  url: "https://hooks.slack.com/services/YOUR/ACTUAL/SLACK/WEBHOOK"
```

### To customize Teams webhook:
Edit `contact-points.yaml` and update the Teams URL:

```yaml
settings:
  url: "https://your-actual-teams-webhook-url"
```

### To customize webhook endpoint:
Edit `contact-points.yaml` and update the webhook URL:

```yaml
settings:
  url: "https://your-actual-webhook-endpoint.com/alert"
```

## Deployment

The Contact Points are automatically deployed during the Grafana installation process via the GitHub Actions workflow. The configuration is mounted into the Grafana container at:

- Contact Points: `/bitnami/grafana/conf/provisioning/notifiers`
- Notification Policies: `/bitnami/grafana/conf/provisioning/alerting/notification-policies`

## Verification

After deployment, you can verify the Contact Points are configured by:

1. Accessing Grafana UI
2. Going to Alerting > Contact Points
3. You should see the configured contact points listed

## Troubleshooting

If Contact Points are not working:

1. Check the Grafana logs for any configuration errors
2. Verify the webhook URLs are accessible
3. Ensure SMTP settings are correct in the main Grafana configuration
4. Check that the ConfigMaps are properly mounted in the Grafana pod 
