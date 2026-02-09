# CookFlow Testing Guide

Comprehensive testing documentation for developers and QA testers.

## 🎯 Testing Strategy

CookFlow uses multiple testing approaches:
1. **Unit Tests** - Individual function testing
2. **Widget Tests** - UI component testing
3. **Integration Tests** - End-to-end flow testing
4. **Manual Testing** - User acceptance testing

---

## 🧪 Automated Testing

### Running Tests

```bash
# Run all tests
cd cookflow_app
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/services/api_service_test.dart

# Run in verbose mode
flutter test --verbose
```

### Backend Tests

```bash
cd backend
npm test

# With coverage
npm run test:coverage

# Watch mode
npm run test:watch
```

---

## 📋 Manual Testing Checklist

### ✅ Authentication Flow

**Sign Up (Email/Password)**
- [ ] Open app for first time
- [ ] Tap "Sign Up"
- [ ] Enter valid email and password
- [ ] Enter display name
- [ ] Tap "Create Account"
- [ ] Verify email verification sent
- [ ] Check email and click verification link
- [ ] Return to app and refresh

**Sign Up (Google)**
- [ ] Tap "Sign Up with Google"
- [ ] Select Google account
- [ ] Grant permissions
- [ ] Verify automatic sign-in
- [ ] Check profile populated with Google info

**Sign In**
- [ ] Enter registered email
- [ ] Enter correct password
- [ ] Tap "Sign In"
- [ ] Verify successful login
- [ ] Check recipes loaded from cloud

**Password Reset**
- [ ] Tap "Forgot Password"
- [ ] Enter registered email
- [ ] Check password reset email received
- [ ] Click reset link
- [ ] Set new password
- [ ] Sign in with new password

**Sign Out**
- [ ] Go to Profile
- [ ] Tap "Sign Out"
- [ ] Confirm sign out
- [ ] Verify redirect to login screen

---

### ✅ Recipe Extraction

**Basic Extraction**
- [ ] Go to "Extract Recipe" tab
- [ ] Paste valid recipe text (50+ chars)
- [ ] Tap "Extract Recipe"
- [ ] Verify loading indicator appears
- [ ] Check extracted data displays correctly:
  - [ ] Title is accurate
  - [ ] Servings extracted
  - [ ] Prep time estimated
  - [ ] Cook time estimated
  - [ ] Ingredients formatted (quantity + item)
  - [ ] Steps numbered and clear
  - [ ] Difficulty level assigned
  - [ ] Cuisine type detected
  - [ ] Tags generated

**Edge Cases**
- [ ] Test with short text (\u003c50 chars) - Should show error
- [ ] Test with very long recipe - Should handle gracefully
- [ ] Test with no ingredients - Should adapt or show warning
- [ ] Test with no steps - Should adapt or show warning
- [ ] Test with special characters - Should parse correctly
- [ ] Test with emojis - Should handle properly

**Save Recipe**
- [ ] After extraction, tap "Save Recipe"
- [ ] Verify success message
- [ ] Navigate to "Saved Recipes"
- [ ] Confirm recipe appears in list
- [ ] Tap recipe to view details
- [ ] Verify all data persisted correctly

---

### ✅ Saved Recipes

**View Recipes**
- [ ] Go to "Saved Recipes" tab
- [ ] Verify all saved recipes displayed
- [ ] Check recipe cards show:
  - [ ] Recipe title
  - [ ] Cook time
  - [ ] Difficulty badge
  - [ ] Cuisine type
  - [ ] Favorite star (if marked)

**Search Recipes**
- [ ] Tap search bar
- [ ] Enter recipe name
- [ ] Verify filtered results
- [ ] Clear search
- [ ] Confirm all recipes return

**Filter Recipes**
- [ ] Tap filter icon
- [ ] Filter by cuisine (e.g., "Italian")
- [ ] Verify only Italian recipes show
- [ ] Filter by difficulty
- [ ] Filter by tags
- [ ] Clear filters

**Recipe Details**
- [ ] Tap any recipe
- [ ] Verify full details displayed:
  - [ ] Title, servings, times
  - [ ] Complete ingredient list
  - [ ] Step-by-step instructions
  - [ ] Notes section
  - [ ] Action buttons visible

**Edit Recipe**
- [ ] Open recipe details
- [ ] Tap "Edit" button
- [ ] Modify title
- [ ] Update servings
- [ ] Change ingredients
- [ ] Edit steps
- [ ] Tap "Save Changes"
- [ ] Verify updates persisted

**Delete Recipe**
- [ ] Swipe left on recipe card (or tap delete in details)
- [ ] Confirm deletion
- [ ] Verify recipe removed from list
- [ ] Check deleted from Firestore (if synced)

**Favorite Recipe**
- [ ] Tap star icon on recipe card
- [ ] Verify star fills in
- [ ] Recipe moves to favorites section
- [ ] Unfavorite and verify removal

---

### ✅ Grocery Lists

**Generate from Recipe**
- [ ] Open a saved recipe
- [ ] Tap "Generate Grocery List"
- [ ] Verify loading indicator
- [ ] Check grocery list created
- [ ] Verify items categorized correctly:
  - [ ] Produce
  - [ ] Dairy
  - [ ] Meat & Seafood
  - [ ] Pantry staples
  - [ ] Other categories

**Generate from Multiple Recipes**
- [ ] Go to grocery list screen
- [ ] Tap "Add Recipes"
- [ ] Select 2-3 recipes
- [ ] Tap "Generate"
- [ ] Verify combined list created
- [ ] Check duplicate items merged

**Checklist Interaction**
- [ ] Tap checkbox next to item
- [ ] Verify item marked as checked
- [ ] Check strikethrough applied
- [ ] Uncheck item
- [ ] Verify checkbox unchecked

**Edit Grocery Items**
- [ ] Tap item to edit
- [ ] Change quantity
- [ ] Update item name
- [ ] Save changes
- [ ] Verify updates displayed

**Add Custom Item**
- [ ] Tap "+ Add Item"
- [ ] Enter item name
- [ ] Enter quantity
- [ ] Select category
- [ ] Save
- [ ] Verify item added to list

**Delete Item**
- [ ] Swipe left on item
- [ ] Tap "Delete"
- [ ] Verify item removed

**Affiliate Links**
- [ ] Tap item with affiliate link
- [ ] Verify Amazon/Instacart link opens
- [ ] Check correct product displayed
- [ ] Return to app

**Share Grocery List**
- [ ] Tap "Share" button
- [ ] Select sharing method (text, email, etc.)
- [ ] Verify formatted list sent
- [ ] Check all items included

**Clear Completed Items**
- [ ] Check off several items
- [ ] Tap "Clear Completed"
- [ ] Confirm action
- [ ] Verify checked items removed

---

### ✅ Pantry Management

**Add Pantry Item**
- [ ] Go to "Pantry" tab
- [ ] Tap "+" button
- [ ] Enter item name (e.g., "Milk")
- [ ] Enter quantity (e.g., "1 gallon")
- [ ] Select category (e.g., "Dairy")
- [ ] Set expiry date (optional)
- [ ] Tap "Save"
- [ ] Verify item appears in pantry

**View Pantry Items**
- [ ] Check all items displayed
- [ ] Verify categories shown
- [ ] Check expiry dates visible
- [ ] Test scroll performance

**Search Pantry**
- [ ] Tap search bar
- [ ] Enter item name
- [ ] Verify filtered results
- [ ] Clear search

**Filter by Category**
- [ ] Tap filter/category dropdown
- [ ] Select "Produce"
- [ ] Verify only produce items shown
- [ ] Clear filter

**Edit Pantry Item**
- [ ] Tap item to edit
- [ ] Update quantity
- [ ] Change expiry date
- [ ] Save changes
- [ ] Verify updates displayed

**Delete Pantry Item**
- [ ] Swipe left on item
- [ ] Tap "Delete"
- [ ] Confirm deletion
- [ ] Verify item removed

**Expiry Warnings**
- [ ] Add item expiring in 2 days
- [ ] Check yellow warning shows
- [ ] Add item expiring today
- [ ] Check red alert shows
- [ ] Add item already expired
- [ ] Verify red alert and warning text

---

### ✅ Meal Planning

**Create Meal Plan**
- [ ] Go to "Meal Plan" tab
- [ ] Select a future date
- [ ] Tap "Add Meal"
- [ ] Choose meal type (Breakfast/Lunch/Dinner)
- [ ] Select recipe from list
- [ ] Tap "Save"
- [ ] Verify meal added to calendar

**View Calendar**
- [ ] Check calendar view shows planned meals
- [ ] Swipe between weeks
- [ ] Tap date to see meals
- [ ] Verify different meal types color-coded

**Edit Meal Plan**
- [ ] Tap on planned meal
- [ ] Change recipe
- [ ] Update meal type
- [ ] Save changes
- [ ] Verify updates reflected

**Delete Meal from Plan**
- [ ] Tap planned meal
- [ ] Tap "Remove from Plan"
- [ ] Confirm deletion
- [ ] Check meal removed from calendar

**Generate Grocery List from Plan**
- [ ] View meal plan for week
- [ ] Tap "Generate Weekly Grocery List"
- [ ] Verify all recipes' ingredients combined
- [ ] Check list organized by category

---

### ✅ Profile & Settings

**View Profile**
- [ ] Go to "Profile" tab
- [ ] Verify user info displayed:
  - [ ] Display name
  - [ ] Email addressemail verification status
  - [ ] Member since date
  - [ ] Last sign-in time
  - [ ] Account plan (Free/Premium)

**Edit Profile**
- [ ] Tap "Edit" button
- [ ] Attempt to change display name
- [ ] Verify feature coming soon message
  (Currently not fully implemented)

**Email Verification**
- [ ] If email not verified, tap "Verify"
- [ ] Check email sent
- [ ] Click verification link
- [ ] Return to app and refresh
- [ ] Verify green checkmark appears

**Notification Settings**
- [ ] Toggle notifications switch
- [ ] Verify preference saved
- [ ] Check snackbar confirms change
- [ ] Close and reopen app
- [ ] Verify setting persisted

**Theme Settings**
- [ ] Go to Settings (from Profile)
- [ ] Change theme to Dark
- [ ] Verify app switches to dark mode
- [ ] Change to Light
- [ ] Verify light mode applied
- [ ] Change to System
- [ ] Toggle device system theme
- [ ] Verify app follows system

**Change Password**
- [ ] Tap "Change Password"
- [ ] Confirm sending reset email
- [ ] Check email received
- [ ] Click reset link
- [ ] Set new password
- [ ] Sign in with new password

**Delete Account**
- [ ] Tap "Delete Account"
- [ ] Read warning about permanent deletion
- [ ] Confirm deletion
- [ ] Verify loading dialog appears
- [ ] Check account deleted:
  - [ ] Firestore data removed
  - [ ] Auth account removed
  - [ ] Redirected to login screen
- [ ] Try to sign in
- [ ] Verify account no longer exists

---

### ✅ Dark Mode

**Theme Consistency**
- [ ] Enable dark mode
- [ ] Navigate through all screens:
  - [ ] Extraction Screen
  - [ ] Saved Recipes
  - [ ] Grocery List
  - [ ] Pantry
  - [ ] Meal Plan
  - [ ] Profile
  - [ ] Settings
- [ ] Verify all use dark theme colors
- [ ] Check text is readable
- [ ] Verify no white flash on navigation

**Dynamic Theming**
- [ ] Switch theme while app is running
- [ ] Verify instant update
- [ ] Check no visual glitches
- [ ] Test system theme switching

---

### ✅ Data Sync (Firebase)

**Cloud Sync After Sign-In**
- [ ] Sign in on Device A
- [ ] Create recipe on Device A
- [ ] Sign in on Device B (same account)
- [ ] Verify recipe appears on Device B

**Real-time Sync**
- [ ] Have both devices signed in
- [ ] Add pantry item on Device A
- [ ] Check item appears on Device B
  (Note: May require refresh in current implementation)

**Offline Functionality**
- [ ] Disable internet on device
- [ ] View saved recipes - Should work
- [ ] Extract recipe - Should fail gracefully
- [ ] Add pantry item - Should save locally
- [ ] Enable internet
- [ ] Verify data syncs to cloud

---

### ✅ Performance Testing

**App Launch Time**
- [ ] Cold start (app not in memory)
- [ ] Measure time to fully load
- [ ] Target: \u003c 3 seconds

**Recipe Extraction Speed**
- [ ] Paste medium recipe (~200 words)
- [ ] Start timer on "Extract" tap
- [ ] Measure time until results display
- [ ] Target: \u003c 10 seconds (AI dependent)

**Scroll Performance**
- [ ] Navigate to Saved Recipes with 20+ recipes
- [ ] Scroll rapidly
- [ ] Check for lag or frame drops
- [ ] Should be smooth 60fps

**Database Operations**
- [ ] Add 100 pantry items via automation
- [ ] Measure query time
- [ ] Target: \u003c 1 second

**Memory Usage**
- [ ] Use Android Studio Profiler / Xcode Instruments
- [ ] Monitor memory during normal usage
- [ ] Check for memory leaks
- [ ] Target: \u003c 200MB for normal usage

---

## 🐛 Bug Reporting Template

When finding bugs, report with this format:

```markdown
**Title**: [Short description of bug]

**Priority**: High / Medium / Low

**Environment**:
- Device: iPhone 14 Pro / Pixel 7
- OS Version: iOS 16.5 / Android 13
- App Version: 1.0.0

**Steps to Reproduce**:
1. Open app
2. Tap "Extract Recipe"
3. Paste long recipe text
4. Tap "Extract"

**Expected Behavior**:
Recipe should extract successfully

**Actual Behavior**:
App crashes with error: "Memory overflow"

**Screenshots**:
[Attach screenshots if applicable]

**Logs**:
[Include error logs from console]

**Additional Context**:
Only happens with recipes \u003e500 words
```

---

## ✅ Regression Testing

Before every release, run full regression test on:

### Critical Paths
1. **Sign Up → Extract Recipe → Save → View**
2. **Sign In → Generate Grocery List → Shop → Complete**
3. **Add Pantry Item → Create Meal Plan → Generate List**
4. **Dark Mode Toggle → Navigate All Screens**

### Data Integrity
- Verify no data loss on app restart
- Check Firestore sync accuracy
- Validate local database consistency

---

## 📊 Test Coverage Goals

- **Unit Tests**: \u003e 70%
- **Widget Tests**: \u003e 60%
- **Integration Tests**: \u003e 50%
- **Manual Test Pass Rate**: 100% before release

---

## 🎯 Acceptance Criteria

App is ready for release when:
- [ ] All automated tests pass
- [ ] Manual testing checklist 100% complete
- [ ] No critical bugs
- [ ] No high priority bugs
- [ ] Performance benchmarks met
- [ ] Accessibility standards met
- [ ] Privacy policy reviewed
- [ ] Terms of service approved

---

**Happy Testing! 🧪**

*Last Updated: February 2026*
