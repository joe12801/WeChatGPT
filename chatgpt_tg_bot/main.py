import logging
from telegram import __version__ as TG_VER

try:
    from telegram import __version_info__
except ImportError:
    __version_info__ = (0, 0, 0, 0, 0)  # type: ignore[assignment]

if __version_info__ < (20, 0, 0, "alpha", 1):
    raise RuntimeError(
        f"This example is not compatible with your current PTB version {TG_VER}. To view the "
        f"{TG_VER} version of this example, "
        f"visit https://docs.python-telegram-bot.org/en/v{TG_VER}/examples.html"
    )
from telegram import ForceReply, Update
from telegram.ext import Application, CommandHandler, ContextTypes, MessageHandler, filters
import requests
import json

# Enable logging
logging.basicConfig(
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s", level=logging.INFO
)
logger = logging.getLogger(__name__)

def ask(prompt, conversation):
    try:
        url = "https://api.henray.site:8444/chatgpt/ask"

        payload = json.dumps({
            "prompt": prompt,
            "conversation": conversation
        })
        headers = {
            'Access-Token': 'dcb363a1d050f6764fc0555471966d17',
            'Content-Type': 'application/json'
        }

        response = requests.request("POST", url, headers=headers, data=payload)

        return response.json()["response"]
    except Exception as e:
        return f"出错了: {e}"

# Define a few command handlers. These usually take the two arguments update and
# context.
async def start(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    """Send a message when the command /start is issued."""
    user = update.effective_user
    await update.message.reply_html(
        rf"Hi {user.mention_html()}!",
        reply_markup=ForceReply(selective=True),
    )



async def echo_command(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    """Echo the user message."""
    logger.info(f"{update.message.from_user} ask: {update.message.text}")
    try:
        response = ask(update.message.text, str(update.message.from_user.id))
        await update.message.reply_markdown(response)
    except Exception as e:
        logger.error("error " + str(e))
        await update.message.reply_text(str(e))


def main() -> None:
    """Start the bot."""
    # Create the Application and pass it your bot's token.
    # proxy_url = 'http://127.0.0.1:7890'  # can also be a https proxy
    application = Application.builder() \
        .token("AAEES386X-HBhNOtRazAvb9cTYaj05ilSss") \
        .build()

    # on different commands - answer in Telegram
    application.add_handler(CommandHandler("start", start))

    # on non command i.e message - echo the message on Telegram
    application.add_handler(MessageHandler(filters.TEXT & ~filters.COMMAND, echo_command))

    # Run the bot until the user presses Ctrl-C
    application.run_polling()


if __name__ == "__main__":
    main()

