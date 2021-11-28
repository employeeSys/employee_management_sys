create view emp_view as select emp_name, manager_id, department_id, salary_uid from employees;
select * from emp_view where salary_uid = (select sal_uid from salary where designation = 'Manager');
select emp_id, CONCAT('Leaves -> ', COUNT(*)) as Leave_Count from leave group by emp_id order by Leave_Count DESC
select * from employees where emp_id = (select emp_id from leave group by emp_id having COUNT(emp_id) = (select COUNT(*) as Leave_Count from leave group by emp_id order by Leave_Count ASC OFFSET 0 ROWS FETCH NEXT 1 ROWS ONLY)OFFSET 0 ROWS FETCH NEXT 1 ROWS ONLY)
select * from employees where emp_id = (select emp_id from leave group by emp_id having COUNT(emp_id) = (select COUNT(*) as Leave_Count from leave group by emp_id order by Leave_Count DESC OFFSET 0 ROWS FETCH NEXT 1 ROWS ONLY))
select dept_name, COUNT(dept_name) as DEPT_STRENGTH from emp_view e LEFT JOIN departments d on e.department_id = d.dept_id group by dept_name; 
select * from emp_view inner join salary on emp_view.salary_uid = salary.sal_uid;
select proj_name, COUNT(proj_name) as TOTAL_CONTRIBUTORS from projects p RIGHT JOIN emp_view e on e.manager_id = p.emp_id group by proj_name;
