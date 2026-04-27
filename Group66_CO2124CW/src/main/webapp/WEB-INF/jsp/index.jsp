<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>

<!DOCTYPE html>
<html>
<head>
    <title>HQ Admin Dashboard</title>
    <style>
        body { font-family: sans-serif; background-color: #f4f7f6; padding: 20px; }
        .stats-card { background: #fff; padding: 15px; border-radius: 8px; margin-bottom: 20px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .btn-disabled { opacity: 0.5; cursor: not-allowed; filter: grayscale(1); }
        .tooltip { position: relative; display: inline-block; }
        .tooltip .tooltiptext {
            visibility: hidden; width: 140px; background-color: black; color: #fff;
            text-align: center; border-radius: 6px; padding: 5px; position: absolute; z-index: 1; bottom: 125%; left: 50%; margin-left: -70px;
        }
        .tooltip:hover .tooltiptext { visibility: visible; }
        table { width: 100%; border-collapse: collapse; background: white; margin-bottom: 20px;}
        th, td { border: 1px solid #ddd; padding: 12px; text-align: left; }
        th { background-color: #f8f9fa; }
        .login-card { border: 1px solid #ccc; background: white; padding: 30px; border-radius: 8px; display: inline-block; width: 300px; box-shadow: 0 4px 6px rgba(0,0,0,0.1); }
        .hidden { display: none !important; }

        .btn-promote {
            background-color: #ffc107;
            color: black;
            border: none;
            padding: 5px 10px;
            border-radius: 4px;
            cursor: pointer;
        }

        .btn-promote:disabled {
            background-color: #e9ecef;
            color: #adb5bd;
            cursor: not-allowed;
        }

        .tab-btn {
            padding: 10px 25px;
            border: none;
            background: none;
            font-size: 16px;
            font-weight: bold;
            cursor: pointer;
            color: #666;
            transition: 0.3s;
        }

        .tab-btn:hover {
            color: #007bff;
        }

        .active-tab {
            color: #007bff;
            border-bottom: 3px solid #007bff;
        }
    </style>
</head>
<body>

<div id="login-section" style="text-align: center; margin-top: 50px;">
    <div class="login-card">
        <h2>HQ Admin Login</h2>
        <div id="login-error" style="color: red; display: none; margin-bottom: 10px;">Invalid username or password.</div>
        <input type="text" id="user" placeholder="Username" style="width:100%; padding:8px; margin-bottom:10px;"><br>
        <input type="password" id="pass" placeholder="Password" style="width:100%; padding:8px; margin-bottom:10px;"><br>
        <button onclick="doLogin()" style="width:100%; padding:10px; background:#007bff; color:white; border:none; cursor:pointer;">Sign In</button>
    </div>
</div>

<div id="main-app-area" class="hidden">

    <div id="message-container"></div>

    <div style="display: flex; justify-content: space-between; align-items: center;">
        <h1>HQ Admin Dashboard</h1>
        <button onclick="doLogout()" style="background:#6c757d; color:white; border:none; padding:8px 15px; border-radius:4px; cursor:pointer;">Logout</button>
    </div>

    <div class="view-switcher" style="margin-bottom: 20px; border-bottom: 2px solid #eee; padding-bottom: 10px;">
        <button onclick="switchView('employees')" id="tab-employees" class="tab-btn active-tab">
            Employees
        </button>
        <button onclick="switchView('departments')" id="tab-departments" class="tab-btn">
            Departments
        </button>
    </div>

    <div id="dashboard-section">
        <div class="stats-card">
            <h3>Total Employees: <span id="employeeCount">0</span></h3>
        </div>

        <div style="margin-bottom: 20px;">
            <input type="text" id="mainSearch" onkeyup="filterTable()"
                   placeholder="Search by Name, ID, or Department..."
                   style="width: 100%; padding: 12px; border: 1px solid #ddd; border-radius: 8px; font-size: 16px;">
        </div>

        <sec:authorize access="hasRole('HR')">
            <button onclick="openCreateModal()" style="background-color: #28a745; color: white; padding: 10px; border: none; border-radius: 4px; cursor: pointer; margin-bottom: 10px;">
                + Hire New Employee
            </button>
        </sec:authorize>

        <div style="margin-bottom: 20px; padding: 15px; background: #f8f9fa; border-radius: 8px; border: 1px solid #e9ecef;">
            <label><strong>Direct ID Lookup (Returns 404 if missing):</strong></label>
            <div style="display: flex; gap: 10px; margin-top: 5px;">
                <input type="number" id="lookupId" placeholder="Enter Exact Employee ID..."
                       style="flex-grow: 1; padding: 10px; border: 1px solid #ccc; border-radius: 4px;">
                <button onclick="lookupEmployee()"
                        style="background: #007bff; color: white; border: none; padding: 10px 20px; border-radius: 4px; cursor: pointer;">
                    Find ID
                </button>
            </div>
            <p id="lookup-error" style="color: red; display: none; margin-top: 10px; font-weight: bold;"></p>
        </div>

        <table id="employeeTable">
            <thead>
            <tr>
                <th>Name</th>
                <th>Email</th>
                <th>Department</th>
                <th>Salary</th>
                <th>Access Level</th>
                <th>Role</th>
                <th>Actions</th>
            </tr>
            </thead>
            <tbody id="employeeTableBody"> </tbody>
        </table>
    </div>

    <div id="department-section" class="hidden">
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
            <h2>Department Management</h2>
            <button id="addDeptBtn" onclick="openDeptModal()" class="btn-primary" style="display:none; background:#28a745; color:white; border:none; padding:10px 20px; border-radius:4px; cursor:pointer;">+ Add New Department</button>
        </div>

        <table class="admin-table">
            <thead>
            <tr>
                <th>ID</th>
                <th>Department Name</th>
                <th>Building / Location</th>
                <th>Annual Budget</th>
            </tr>
            </thead>
            <tbody id="departmentTableBody">
            </tbody>
        </table>
    </div>

    <div id="editModal" class="hidden" style="position: fixed; z-index: 2; left: 0; top: 0; width: 100%; height: 100%; background-color: rgba(0,0,0,0.5);">
        <div style="background-color: white; margin: 20px auto; padding: 25px; border-radius: 8px; width: 400px; box-shadow: 0 5px 15px rgba(0,0,0,0.3); max-height: 85vh; overflow-y: auto; position: relative;">

            <h2>Edit Employee</h2>
            <input type="hidden" id="editId">

            <label>Name:</label><br>
            <input type="text" id="editName" style="width:100%; margin-bottom:10px;"><br>

            <label>Email:</label><br>
            <input type="email" id="editEmail" class="form-input" placeholder="example@hq.com" style="width:100%; padding:8px; margin-bottom:15px; border: 1px solid #ccc;">

            <label>Address:</label><br>
            <input type="text" id="editAddress" style="width:100%; margin-bottom:10px;"><br>

            <label>Salary:</label><br>
            <input type="number" id="editSalary" style="width:100%; margin-bottom:10px;"><br>

            <label>Department:</label><br>
            <select id="editDepartment" style="width:100%; margin-bottom:10px;"></select><br>

            <label>Role:</label><br>
            <select id="editRole" style="width:100%; margin-bottom:20px;"></select><br>

            <label>Contract Type:</label><br>
            <select id="editContract" style="width:100%; margin-bottom:20px;">
                <option value="Full-Time">Full-Time</option>
                <option value="Part-Time">Part-Time</option>
                <option value="Contract">Contract</option>
            </select><br>

            <div style="text-align: right; margin-top: 10px;">
                <button onclick="closeModal()" style="background:#6c757d; color:white; border:none; padding:8px 15px; cursor:pointer; border-radius: 4px;">Cancel</button>
                <button onclick="submitEdit()" style="background:#28a745; color:white; border:none; padding:8px 15px; cursor:pointer; border-radius: 4px;">Save Changes</button>
            </div>
        </div>
    </div>

<div id="createModal" class="hidden" style="position: fixed; z-index: 5; left: 0; top: 0; width: 100%; height: 100%; background-color: rgba(0,0,0,0.5);">
    <div style="background-color: white; margin: 20px auto; padding: 25px; border-radius: 8px; width: 400px; box-shadow: 0 5px 15px rgba(0,0,0,0.3); max-height: 85vh; overflow-y: auto; position: relative;">
        <h2 style="margin-top:0;">Hire New Employee</h2>
        <p id="create-error" style="color: red; display: none; font-size: 0.9em;">Please fill in all highlighted fields.</p>
        <label>Full Name:</label>
        <input type="text" id="newName" class="form-input" placeholder="e.g. Chuck E. Cheese" style="width:100%; padding:8px; margin-bottom:15px; border: 1px solid #ccc;">
        <label>Email:</label><br>
        <input type="email" id="newEmail" class="form-input" placeholder="example@hq.com" style="width:100%; padding:8px; margin-bottom:15px; border: 1px solid #ccc;">
        <label>Address:</label>
        <input type="text" id="newAddress" class="form-input" placeholder="123 Pizza Planet Way" style="width:100%; padding:8px; margin-bottom:15px; border: 1px solid #ccc;">
        <label>Start Date:</label>
        <input type="date" id="newStartDate" class="form-input" style="width:100%; padding:8px; margin-bottom:15px; border: 1px solid #ccc;">
        <label>Salary:</label>
        <input type="number" id="newSalary" class="form-input" placeholder="75000" style="width:100%; padding:8px; margin-bottom:15px; border: 1px solid #ccc;">
        <label>Contract Type:</label>
        <select id="newContractType" class="form-input" style="width:100%; padding:8px; margin-bottom:15px; border: 1px solid #ccc;">
            <option value="">-- Select Type --</option>
            <option value="Full-Time">Full-Time</option>
            <option value="Part-Time">Part-Time</option>
        </select>
        <label>Department:</label>
        <select id="newDepartment" class="form-input" style="width:100%; padding:8px; margin-bottom:15px; border: 1px solid #ccc;"></select>
        <label>Role:</label>
        <select id="newRole" class="form-input" style="width:100%; padding:8px; margin-bottom:20px; border: 1px solid #ccc;"></select>
        <div style="text-align: right;">
            <button onclick="closeCreateModal()" style="background:#6c757d; color:white; border:none; padding:10px 15px; border-radius:4px; cursor:pointer;">Cancel</button>
            <button onclick="submitCreate()" style="background:#28a745; color:white; border:none; padding:10px 20px; border-radius:4px; cursor:pointer;">Confirm Hire</button>
        </div>
    </div>
</div>

<div id="assignmentModal" class="hidden" style="position: fixed; z-index: 5; left: 0; top: 0; width: 100%; height: 100%; background-color: rgba(0,0,0,0.5);">
    <div style="background-color: white; margin: 10% auto; padding: 25px; border-radius: 8px; width: 350px;">
        <h3>Change Department Assignment</h3>
        <p>Employee: <span id="assignEmployeeName" style="font-weight:bold;"></span></p>
        <input type="hidden" id="assignEmployeeId">
        <label>Select New Department:</label><br>
        <select id="newAssignDepartment" style="width:100%; padding:8px; margin-top:10px; margin-bottom:20px;"></select>
        <div style="text-align: right;">
            <button onclick="closeAssignmentModal()" style="background:#6c757d; color:white; border:none; padding:8px 15px; border-radius:4px;">Cancel</button>
            <button onclick="submitAssignmentChange()" style="background:#007bff; color:white; border:none; padding:8px 15px; border-radius:4px;">Update Assignment</button>
        </div>
    </div>
</div>

<div id="deptModal" class="hidden" style="position: fixed; z-index: 10; left: 0; top: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.5);">
    <div style="background: white; margin: 10% auto; padding: 25px; border-radius: 8px; width: 400px;">
        <h3>Create New Department</h3>
        <label>Name:</label>
        <input type="text" id="deptName" style="width:100%; margin-bottom:10px;">
        <label>Building / Location:</label>
        <input type="text" id="deptLocation" style="width:100%; margin-bottom:10px;">
        <label>Budget:</label>
        <input type="number" id="deptBudget" style="width:100%; margin-bottom:10px;" placeholder="Must be > 0">
        <p id="dept-error" style="color:red; display:none;"></p>
        <div style="text-align: right; margin-top:20px;">
            <button onclick="closeDeptModal()">Cancel</button>
            <button onclick="submitCreateDept()" style="background:#28a745; color:white;">Create</button>
        </div>
    </div>
</div>

</body>
</html>
<script>
    // Security Flags from Spring Security
    const isHR = <sec:authorize access="hasRole('HR')">true</sec:authorize><sec:authorize access="!hasRole('HR')">false</sec:authorize>;

    // --- AUTH LOGIC ---

    async function doLogin() {
        const user = document.getElementById('user').value;
        const pass = document.getElementById('pass').value;

        const formData = new URLSearchParams();
        formData.append('username', user);
        formData.append('password', pass);

        const response = await fetch('/api/login', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded'
            },
            body: formData
        });

        if (response.ok) {
            window.location.href = "/";
        } else {
            document.getElementById('login-error').style.display = 'block';
        }
    }

    async function doLogout() {
        try {
            const response = await fetch('/logout', { method: 'POST' });
            if (response.ok || response.status === 302) {
                window.location.href = "/";
            }
        } catch (err) {
            console.error("Logout failed", err);
            window.location.reload();
        }
    }

    // --- DATA LOGIC ---

    let allEmployees = [];

    async function fetchEmployees() {
        try {
            const response = await fetch('/api/home/summary', { credentials: 'include' });

            const contentType = response.headers.get("content-type");
            if (!contentType || !contentType.includes("application/json")) {
                console.error("Oops! Server sent HTML instead of JSON. Are you logged in?");
                return;
            }

            if (response.ok) {
                const data = await response.json();
                console.log("Data received from server:", data);

                allEmployees = data.employees || [];
                renderTable(allEmployees);
                document.getElementById('employeeCount').innerText = data.employeeCount;

                // FIX: Hide login, show the NEW main shell
                document.getElementById('login-section').classList.add('hidden');
                document.getElementById('main-app-area').classList.remove('hidden');

            } else if (response.status === 401) {
                // FIX: Show login, hide the NEW main shell
                document.getElementById('login-section').classList.remove('hidden');
                document.getElementById('main-app-area').classList.add('hidden');
            }
        } catch (err) {
            console.error("Dashboard load failed:", err);
        }
    }

    function filterTable() {
        const searchTerm = document.getElementById('mainSearch').value.toLowerCase();

        const filtered = allEmployees.filter(emp => {
            const nameMatch = emp.name.toLowerCase().includes(searchTerm);
            const idMatch = emp.id.toString().includes(searchTerm);
            const deptMatch = (emp.department && emp.department.name)
                ? emp.department.name.toLowerCase().includes(searchTerm)
                : false;

            return nameMatch || idMatch || deptMatch;
        });

        renderTable(filtered);
    }

    function renderTable(employees) {
        const tbody = document.getElementById('employeeTableBody');
        tbody.innerHTML = '';

        const today = new Date();
        const sixMonthsAgo = new Date();
        sixMonthsAgo.setMonth(today.getMonth() - 6);

        employees.forEach(emp => {
            const startDate = new Date(emp.startDate);
            const isEligible = startDate <= sixMonthsAgo;

            const row = document.createElement('tr');
            const promoteBtn = `
            <div class="tooltip" title="\${isEligible ? 'Promote this employee' : 'Ineligible: Must work 6+ months'}">
                <button onclick="promoteEmployee(\${emp.id})" class="btn-promote" \${isEligible ? '' : 'disabled'}>
                    Promote
                </button>
            </div>`;

            let actionButtons = isHR ? `
                <button onclick="openEditModal(\${emp.id})">Edit</button>
                <button onclick="openAssignmentModal(\${emp.id}, '\${emp.name}')" style="background:#17a2b8; color:white;">Assign</button>
                <button onclick="removeAssignment(\${emp.id})" style="background:#6c757d; color:white;">Unassign</button>
                <button onclick="deleteEmployee(\${emp.id}, '\${emp.name}')" style="background:#dc3545; color:white;">Delete</button>
                \${promoteBtn}
            ` : `<div class="tooltip"><button class="btn-disabled">Edit</button><span class="tooltiptext">Must be HR</span></div>`;

            row.innerHTML = `
                <td>\${emp.name}</td>
                <td>\${emp.email || 'N/A'}</td>
                <td>\${emp.department ? emp.department.name : 'N/A'}</td>
                <td>\${emp.salary ? emp.salary : 'N/A'}</td>
                <td>\${emp.assignment ? emp.assignment.role : 'N/A'}</td>
                <td>\${emp.assignment ? emp.assignment.accessLevel : 'N/A'}</td>
                <td>\${actionButtons}</td>
            `;

            tbody.appendChild(row);
        });
    }

    async function deleteEmployee(id, name) {
        if (!id) return;
        if (!confirm(`Are you sure you want to delete \${name}?`)) return;

        try {
            const res = await fetch(`/api/employees/\${id}`, { method: 'DELETE' });
            if (res.ok) {
                fetchEmployees();
                showMessage("Employee deleted successfully", "green");
            } else {
                const errorData = await res.json();
                alert("Delete failed: " + (errorData.message || "Unknown error"));
            }
        } catch (err) {
            console.error("Delete request failed", err);
        }
    }

    function showMessage(text, color) {
        const container = document.getElementById('message-container');
        container.innerHTML = `<div style="background:${color}; color:white; padding:10px; margin-bottom:10px;">${text}</div>`;
    }

    async function loadDropdowns() {
        try {
            const [deptRes, roleRes] = await Promise.all([
                fetch('/api/departments'),
                fetch('/api/assignments')
            ]);

            if (deptRes.ok && roleRes.ok) {
                const depts = await deptRes.json();
                const roles = await roleRes.json();

                const deptIds = ['editDepartment', 'newDepartment', 'newAssignDepartment'];
                deptIds.forEach(id => {
                    const select = document.getElementById(id);
                    if (select) {
                        select.innerHTML = '<option value="">-- Select Department --</option>';
                        depts.forEach(d => {
                            select.innerHTML += `<option value="\${d.id}">\${d.name}</option>`;
                        });
                    }
                });

                const roleIds = ['editRole', 'newRole'];
                roleIds.forEach(id => {
                    const select = document.getElementById(id);
                    if (select) {
                        select.innerHTML = '<option value="">-- Select Role --</option>';
                        roles.forEach(r => {
                            select.innerHTML += `<option value="\${r.id}">\${r.role} (\${r.accessLevel})</option>`;
                        });
                    }
                });
            }
        } catch (err) {
            console.error("Dropdown sync failed:", err);
        }
    }

    async function removeAssignment(employeeId) {
        if (!confirm("Remove this employee from their department?")) return;
        try {
            const response = await fetch(`/api/assignments/\${employeeId}`, { method: 'DELETE' });
            if (response.ok) {
                showMessage("Employee is now unassigned.", "orange");
                fetchEmployees();
            } else {
                alert("Error: Only HR can remove assignments or employee not found.");
            }
        } catch (err) {
            console.error("Delete assignment failed:", err);
        }
    }

    async function openEditModal(empId) {
        try {
            const response = await fetch(`/api/employees/\${empId}`);
            if (response.ok) {
                const emp = await response.json();

                document.getElementById('editId').value = emp.id || '';
                document.getElementById('editName').value = emp.name || '';
                document.getElementById('editAddress').value = emp.address || '';
                document.getElementById('editSalary').value = emp.salary || '';
                document.getElementById('editContract').value = emp.contractType || '';

                const deptSelect = document.getElementById('editDepartment');
                if (emp.department && deptSelect) deptSelect.value = emp.department.id;
                else deptSelect.value = "";

                const roleSelect = document.getElementById('editRole');
                if (emp.assignment && roleSelect) roleSelect.value = emp.assignment.id;
                else roleSelect.value = "";

                document.getElementById('editModal').classList.remove('hidden');
            } else {
                alert("Could not find employee details.");
            }
        } catch (err) { console.error("Failed to load edit modal:", err); }
    }

    function closeModal() {
        document.getElementById('editModal').classList.add('hidden');
    }

    async function submitEdit() {
        const id = document.getElementById('editId').value;
        const deptId = document.getElementById('editDepartment').value;
        const roleId = document.getElementById('editRole').value;

        const updatedData = {
            name: document.getElementById('editName').value,
            email: document.getElementById('newEmail').value,
            address: document.getElementById('editAddress').value,
            salary: parseFloat(document.getElementById('editSalary').value),
            contractType: document.getElementById('editContract').value
        };

        const url = `/api/employees/\${id}?departmentId=\${deptId}&roleId=\${roleId}`;

        const response = await fetch(url, {
            method: 'PUT',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(updatedData)
        });

        if (response.ok) {
            showMessage("Employee updated with new Department/Assignment!", "green");
            closeModal();
            fetchEmployees();
        }
    }

    function openCreateModal() {
        const inputs = document.querySelectorAll('.form-input');
        inputs.forEach(input => {
            input.value = '';
            input.style.borderColor = '#ccc';
        });
        document.getElementById('create-error').style.display = 'none';
        document.getElementById('createModal').classList.remove('hidden');
        loadDropdowns();
    }

    async function submitCreate() {
        const inputs = document.querySelectorAll('#createModal .form-input');
        let hasError = false;

        inputs.forEach(input => {
            if (!input.value) {
                input.style.borderColor = "red";
                hasError = true;
            } else {
                input.style.borderColor = "#ccc";
            }
        });

        if (hasError) {
            document.getElementById('create-error').style.display = 'block';
            return;
        }

        const deptId = document.getElementById('newDepartment').value;
        const roleId = document.getElementById('newRole').value;

        const newEmployee = {
            name: document.getElementById('newName').value,
            email: document.getElementById('newEmail').value,
            address: document.getElementById('newAddress').value,
            salary: parseFloat(document.getElementById('newSalary').value),
            contractType: document.getElementById('newContractType').value,
            startDate: document.getElementById('newStartDate').value
        };

        const url = `/api/employees/?departmentId=\${deptId}&assignmentId=\${roleId}`;

        const response = await fetch(url, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(newEmployee)
        });

        if (response.ok) {
            closeCreateModal();
            fetchEmployees();
            showMessage("Employee hired successfully!", "green");
        }
    }

    function closeCreateModal() {
        document.getElementById('createModal').classList.add('hidden');
    }

    async function lookupEmployee() {
        const id = document.getElementById('lookupId').value;
        const errorDisplay = document.getElementById('lookup-error');
        errorDisplay.style.display = 'none';
        if (!id) return;

        try {
            const response = await fetch(`/api/employees/\${id}`);
            if (response.status === 404) {
                errorDisplay.innerText = "Error 404: Employee with ID " + id + " not found in the database.";
                errorDisplay.style.display = 'block';
                renderTable([]);
                return;
            }
            if (response.ok) {
                const employee = await response.json();
                renderTable([employee]);
                showMessage("Employee " + id + " found!", "green");
            }
        } catch (err) { console.error("Lookup failed:", err); }
    }

    function openAssignmentModal(id, name) {
        document.getElementById('assignEmployeeId').value = id;
        document.getElementById('assignEmployeeName').innerText = name;
        document.getElementById('assignmentModal').classList.remove('hidden');
    }

    function closeAssignmentModal() {
        document.getElementById('assignmentModal').classList.add('hidden');
    }

    async function submitAssignmentChange() {
        const payload = {
            employeeId: parseInt(document.getElementById('assignEmployeeId').value),
            departmentId: parseInt(document.getElementById('newAssignDepartment').value)
        };

        try {
            const response = await fetch('/api/assignments', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(payload)
            });

            if (response.ok) {
                showMessage("Department reassigned successfully!", "green");
                closeAssignmentModal();
                fetchEmployees();
            } else {
                alert("Failed to reassign. Ensure you selected a department.");
            }
        } catch (err) { console.error("Assignment error:", err); }
    }

    async function promoteEmployee(id) {
        if (!confirm("Are you sure you want to promote this employee? This will increase their salary by 10%.")) return;
        try {
            const response = await fetch(`/api/employees/\${id}/promote`, { method: 'PUT' });
            if (response.ok) {
                const message = await response.text();
                showMessage(message, "green");
                fetchEmployees();
            } else if (response.status === 400) {
                const errorMsg = await response.text();
                alert("Promotion Denied: " + errorMsg);
            } else {
                alert("Error: Only HR can authorize promotions.");
            }
        } catch (err) { console.error("Promotion request failed:", err); }
    }

    function switchView(view) {
        const empSection = document.getElementById('dashboard-section');
        const deptSection = document.getElementById('department-section');
        const empTab = document.getElementById('tab-employees');
        const deptTab = document.getElementById('tab-departments');

        if (view === 'employees') {
            empSection.classList.remove('hidden');
            deptSection.classList.add('hidden');
            empTab.classList.add('active-tab');
            deptTab.classList.remove('active-tab');
            fetchEmployees();
        } else {
            deptSection.classList.remove('hidden');
            empSection.classList.add('hidden');
            deptTab.classList.add('active-tab');
            empTab.classList.remove('active-tab');
            fetchDepartments();
        }
    }

    async function fetchDepartments() {
        try {
            const response = await fetch('/api/departments');
            if (response.ok) {
                const departments = await response.json();
                renderDeptTable(departments);

                // FIX: Used the 'isHR' variable defined at the top instead of 'currentUserRole'
                if (isHR) {
                    const btn = document.getElementById('addDeptBtn');
                    if (btn) btn.style.display = 'block';
                }
            }
        } catch (err) { console.error("Failed to load departments", err); }
    }

    function renderDeptTable(data) {
        const tbody = document.getElementById('departmentTableBody');
        tbody.innerHTML = '';
        data.forEach(d => {
            tbody.innerHTML += `
            <tr>
                <td>\${d.id}</td>
                <td><strong>\${d.name}</strong></td>
                <td>\${d.location || 'Main Campus'}</td>
                <td>$\${d.budget.toLocaleString()}</td>
            </tr>`;
        });
    }

    function openDeptModal() {
        document.getElementById('deptName').value = '';
        document.getElementById('deptLocation').value = '';
        document.getElementById('deptBudget').value = '';
        document.getElementById('dept-error').style.display = 'none';
        document.getElementById('deptModal').classList.remove('hidden');
    }

    function closeDeptModal() {
        document.getElementById('deptModal').classList.add('hidden');
    }

    async function submitCreateDept() {
        const name = document.getElementById('deptName').value;
        const location = document.getElementById('deptLocation').value;
        const budget = parseFloat(document.getElementById('deptBudget').value);
        const errorMsg = document.getElementById('dept-error');

        if (isNaN(budget) || budget <= 0) {
            errorMsg.innerText = "Budget must be a positive number.";
            errorMsg.style.display = 'block';
            return;
        }

        try {
            const response = await fetch('/api/departments', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ name, location, budget })
            });

            if (response.ok) {
                closeDeptModal();
                fetchDepartments();
                showMessage("Department created successfully!", "green");
            } else {
                const err = await response.json();
                errorMsg.innerText = err.error || "Failed to create department.";
                errorMsg.style.display = 'block';
            }
        } catch (err) { console.error(err); }
    }

    // FIX: Combined your DOMContentLoaded and window.onload to prevent double-loading
    document.addEventListener("DOMContentLoaded", () => {
        switchView('employees'); // This ensures the right tab starts active and calls fetchEmployees
        loadDropdowns();
    });
</script>
</body>
</html>