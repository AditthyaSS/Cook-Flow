# Push CookFlow to GitHub

## Step 1: Create GitHub Repository
1. Go to https://github.com/new
2. Name: `cookflow` (or your preferred name)
3. Description: `🍳 AI-powered recipe extraction mobile app - Built with Flutter & Gemini AI`
4. Make it Public or Private
5. **DO NOT** check any boxes (no README, .gitignore, or license)
6. Click "Create repository"

## Step 2: Push Your Code

After creating the repository, GitHub will show you commands. Use these:

```bash
# Set your main branch (if not already set)
git branch -M main

# Add your GitHub repository as remote
# Replace YOUR_USERNAME with your actual GitHub username
git remote add origin https://github.com/YOUR_USERNAME/cookflow.git

# Push your code
git push -u origin main
```

## Example with username "aditt":
```bash
git branch -M main
git remote add origin https://github.com/aditt/cookflow.git
git push -u origin main
```

## Step 3: Verify
After pushing, visit your repository URL and you should see all your files!

---

## 🔒 Security Check ✅
Your `.env` file with the Gemini API key is NOT included in the repository (protected by .gitignore).
Only `.env.example` is included as a template for others.

---

## 🎯 What's Included:
- ✅ Complete Flutter mobile app
- ✅ Node.js backend with Gemini AI
- ✅ Comprehensive README files
- ✅ Beautiful UI implementation
- ✅ All Phase 1 features

Ready for Phase 2! 🚀
