const router = require("express").Router();
const { authenticate, authorize } = require("../middleware/auth");
const { getDashboard, getReport } = require("../controllers/adminController");
router.use(authenticate, authorize("ADMIN"));
router.get("/dashboard", getDashboard);
router.get("/report/pdf", getReport);
module.exports = router;